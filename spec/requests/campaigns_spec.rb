require 'spec_helper'

describe "Campaigns" do
  context "/" do
    before(:all) do
      @campaign_with_banners = FactoryGirl.create(:campaign_with_banners)
    end
     
    it "returns a banner" do
      get "/campaigns/#{@campaign_with_banners.id}"
      last_response.content_type.should == "image/png"
    end
  end
end
