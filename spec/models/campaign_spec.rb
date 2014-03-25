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
        @weighted_requests_made[:random].should == 0
        @weighted_requests_made[:weighted].should == 100
        @weighted_requests_made[:current_request].should == :weighted
      end
    end
    context "mixed requests" do
      before(:all) do
        mixed_requests_campaign = FactoryGirl.create(:mixed_requests_campaign)
        @mixed_requests_made = {}
        100.times do
          @mixed_requests_made = mixed_requests_campaign.request(@mixed_requests_made)
        end
      end
      it "returns a new request type based on the ratio and the requests already made" do
        @mixed_requests_made[:random].should == 35
        @mixed_requests_made[:weighted].should == 65
        @mixed_requests_made[:current_request].should_not be_empty
      end
    end
  end
  
  context ".banner_ids_from_redis" do
    context "adds and removes the banner ids to Redis taking into account the ratio" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        @campaign_with_banners = FactoryGirl.create(:campaign_with_banners)
        @campaign_with_banners.banners.last.destroy
      end
      it "contains all the banner ids in Redis (not unique)" do
        #compare the unique values
        @campaign_with_banners.banner_ids_from_redis.values.uniq.size.should == @campaign_with_banners.reload.banner_ids.size
      
        #compare all values
        @campaign_with_banners.banner_ids_from_redis.size.should > @campaign_with_banners.reload.banner_ids.size
      end
    end
    context "updates Redis when the banner weight is updated" do
      # Before each hook used, so Redis can be flushed easily, because the Database Cleaner ignores Redis.
      before(:each) do
        update_campaign = FactoryGirl.create(:update_campaign)
        @old_banner_ids_from_redis = update_campaign.banner_ids_from_redis.values.dup
        update_campaign.banners.first.update_attributes :weight => 10
        @new_banner_ids_from_redis = update_campaign.reload.banner_ids_from_redis.values.dup
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
        @banner_ids_left_and_requests_made = {}
      end
      it "will never return a banner twice unless all banners are already displayed" do
        # simulate 400 requests
        400.times do
          # find ethod used here, because it is the idea to completely move the campaign to Redis
          @banner_ids_left_and_requests_made = Campaign.find(@campaign_with_banners.id).get_banner_and_requests_made(@banner_ids_left_and_requests_made)
          @banner_ids_left_and_requests_made[:current_banner_id].should > 0
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
        banner_ids_left_and_requests_made = {}
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
