require 'spec_helper'

describe "Campaigns" do
  context "/" do
    before(:all) do
      @campaign_with_banners = FactoryGirl.create(:campaign_with_banners4)
    end
     
    it "returns the first banner from the root" do
      get "/"
      last_response.status.should == 302
      last_response.location.ends_with?("/campaigns/#{Campaign.banner_ids_from_redis.first[0]}").should be_true
    end
    
    it "returns the banner from the banner view" do
      get "/campaigns/#{@campaign_with_banners.id}"
      last_response.content_type.should == "image/png"
    end
  end
end
