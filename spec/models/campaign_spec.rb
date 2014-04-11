require 'spec_helper'

describe Campaign do
  before(:all) do
    @redis = ::Redis.connect
  end
  before(:each) do
    # DatabaseCleaner doesn't flush Redis, so we need to do it manually
    @redis.flushdb
  end
  
  it {should have_many :banners}
  
  it {should validate_presence_of :name}
  it {should validate_uniqueness_of :name}
  
  #validatees random_ratio; must be equal or greater then 0 and equal or lower then 100
  it {should allow_value(0).for(:random_ratio)}
  it {should allow_value(100).for(:random_ratio)}
  it {should_not allow_value(-1).for(:random_ratio)}
  it {should_not allow_value(101).for(:random_ratio)}
  
  context ".request(requests_made)"  do
    context "only random requests" do
      before(:all) do
        random_requests_campaign = FactoryGirl.create(:random_requests_campaign)
        @random_requests_made = {}
        100.times do
          @random_requests_made = random_requests_campaign.request(@random_requests_made)
        end
      end
      it "returns a new request type based on the ratio and the requests already made" do
        @random_requests_made[:common_denominator].should == 1
        @random_requests_made[:random].should == 100
        @random_requests_made[:weighted].should == 0
        @random_requests_made[:current_request].should == :random
      end
    end
    context "only weighted requests" do
      before(:all) do
        weighted_requests_campaign = FactoryGirl.create(:weighted_requests_campaign)
        @weighted_requests_made = {}
        100.times do
          @weighted_requests_made = weighted_requests_campaign.request(@weighted_requests_made)
        end
      end
      it "returns a new request type based on the ratio and the requests already made" do
        @weighted_requests_made[:common_denominator].should == 1
        @weighted_requests_made[:random].should == 0
        @weighted_requests_made[:weighted].should == 100
        @weighted_requests_made[:current_request].should == :weighted
      end
    end
    context "mixed requests" do
      before(:all) do
        @mixed_requests_campaign = FactoryGirl.create(:mixed_requests_campaign)
        # For better reading of the test I calculated the common denominator by myself
        @mixed_requests_made = {}
        @common_denominator = 5
        (100 / @common_denominator).times do
          @mixed_requests_made = @mixed_requests_campaign.request(@mixed_requests_made)
        end
        
        @other_mixed_requests_campaign = FactoryGirl.create(:other_mixed_requests_campaign)
        # For better reading of the test I calculated the common denominator by myself
        @other_mixed_requests_made = {}
        @other_common_denominator = 2
        (100 / @other_common_denominator).times do
          @other_mixed_requests_made = @other_mixed_requests_campaign.request(@other_mixed_requests_made)
        end
      end
      it "returns a new request based on the ratio and the requests already made." do
        @mixed_requests_made[:common_denominator].should == @common_denominator # 2
        @mixed_requests_made[:random].should == @mixed_requests_campaign.random_ratio / @common_denominator # 7
        @mixed_requests_made[:weighted].should == (100 - @mixed_requests_campaign.random_ratio) / @common_denominator # 13
        @mixed_requests_made[:current_request].should_not be_empty
        
        @other_mixed_requests_made[:common_denominator].should == @other_common_denominator # 2
        @other_mixed_requests_made[:random].should == @other_mixed_requests_campaign.random_ratio / @other_common_denominator # 33
        @other_mixed_requests_made[:weighted].should == (100 - @other_mixed_requests_campaign.random_ratio) / @other_common_denominator # 17
        @other_mixed_requests_made[:current_request].should_not be_empty
      end
    end
  end
  
  # The function 'find_from_redis' already exists so that's why I named it 'find_from_redis_by_id'
  # I also don't want to override the function #find
  context "#find_from_redis_by_id(id)" do
    # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
    before(:each) do
      #This an ugly factory, but when I reuse the factory 'campaign_with_banners', then when I run the full test, this example will fail
      @campaign_with_banners = FactoryGirl.create(:campaign_with_banners3)
      @second_campaign_with_banners = FactoryGirl.create(:second_campaign_with_banners)
      
      @second_campaign_with_banners.destroy
    end
    it "finds the banner_ids and random_ratio by the id from Redis" do
      Campaign.find_from_redis_by_id(@campaign_with_banners.id).get_banner_ids_from_redis.uniq.size.should == @campaign_with_banners.banner_ids.size
      Campaign.find_from_redis_by_id(@campaign_with_banners.id).random_ratio.should == @campaign_with_banners.random_ratio
      
      # Check if the Campaign is deleted from Redis after the campaign is deleted
      Campaign.find_from_redis_by_id(@second_campaign_with_banners.id).should be_blank
      Campaign.banner_ids_from_redis[@second_campaign_with_banners.id].should be_blank
      Campaign.random_ratio_from_redis[@second_campaign_with_banners.id].should be_blank
    end
  end
  
  # Note that it looks to be weird that the function below are tested in the Campaign model instead of in the Banner model.
  # This is done, because the function 'banner.add_banner_to_redis' won't work without a campaign associated
  context ".get_banner_ids_from_redis" do
    context "adds and removes the banner ids to Redis taking into account the ratio" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        #This an ugly factory, but when I reuse the factory 'campaign_with_banners', then when I run the full test, this example will fail
        @campaign_with_banners = FactoryGirl.create(:campaign_with_banners2)
        @destroyed_banner = @campaign_with_banners.banners.last.destroy
      end
      it "contains all the banner ids and banner paths in Redis (because some banners might be weighted, not every banner_id is unique)" do
        #compare the unique values before and after one banner is destroyed using the 'reload' function
        @campaign_with_banners.get_banner_ids_from_redis.uniq.size.should == @campaign_with_banners.reload.banner_ids.size
        @campaign_with_banners.reload.banners.each do |banner|
          Banner.paths[banner.id].should == banner.image.path
        end
        Banner.paths[@destroyed_banner.id.to_s].should be_blank
        
        #compare all values, assure that the weighted are added 'weighted' times to the array
        @campaign_with_banners.get_banner_ids_from_redis.size.should > @campaign_with_banners.reload.banner_ids.size
      end
    end
    context "updates Redis when the banner weight is updated" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        update_campaign = FactoryGirl.create(:update_campaign)
        @old_banner_ids_from_redis = update_campaign.get_banner_ids_from_redis.dup
        update_campaign.banners.first.update_attributes :weight => 10
        @new_banner_ids_from_redis = update_campaign.reload.get_banner_ids_from_redis.dup
      end
      it "set the new weighted banner ids in Redis" do
        #old weight of the first banner was 2, the new weight is 10
        @old_banner_ids_from_redis.size.should == @new_banner_ids_from_redis.size - 8
      end
    end
  end
  
  context ".get_banner_and_requests_made(requests_made_and_banners_seen)" do
    context "campaign with mixed requests" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        @campaign_with_banners = FactoryGirl.create(:campaign_with_banners)
        
        # This is initiated as nil, because at the first request, this will also be nil
        @banner_ids_left_and_requests_made = nil
      end
      it "will never return a banner twice unless all banners are already displayed" do
        # simulate 400 requests
        400.times do
          # find_from_redis_by_id method used here, because its done the same way in the controller
          @banner_ids_left_and_requests_made = Campaign.find_from_redis_by_id(@campaign_with_banners.id).get_banner_and_requests_made(@banner_ids_left_and_requests_made)
          @banner_ids_left_and_requests_made[:current_banner_id].should > 0
          @banner_ids_left_and_requests_made[:current_banner_path].should_not be_empty
          @banner_ids_left_and_requests_made[:requests_made][:current_request].should be_present
          @banner_ids_left_and_requests_made[:requests_made][:random].should be_present
          @banner_ids_left_and_requests_made[:requests_made][:weighted].should be_present
          @banner_ids_left_and_requests_made[:banner_ids_left].should_not include(@banner_ids_left_and_requests_made[:current_banner_id])
        end
        @banner_ids_left_and_requests_made[:banner_ids_left].size.should == 0
      end
    end
    context "campaign with weighted requests" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        weighted_requests_campaign_with_banners = FactoryGirl.create(:weighted_requests_campaign_with_banners)
        
        # This is initiated as nil, because at the first request, this will also be nil
        banner_ids_left_and_requests_made = nil
        @banner_ids_seen = []
        
        # simulate 10 requests and reset the banner ids left each time, so a new array of banner ids is generated
        10.times do
          banner_ids_left_and_requests_made = weighted_requests_campaign_with_banners.get_banner_and_requests_made(banner_ids_left_and_requests_made)
          @banner_ids_seen << banner_ids_left_and_requests_made[:current_banner_id]
          
          #reset the banner ids to test if the weight is taken into account
          banner_ids_left_and_requests_made[:banner_ids_left] = nil
        end
        @banner_lowest_weight = weighted_requests_campaign_with_banners.banners.order(:weight).first
        @banner_highest_weight = weighted_requests_campaign_with_banners.banners.order(:weight).last
      end
      it "takes the weights into account when getting the banner" do
        #check if the banner with the lowest weight occured less then the other
        @banner_ids_seen.count(@banner_lowest_weight.id).should < @banner_ids_seen.count(@banner_highest_weight.id)
      end
    end
  end
end
