require 'spec_helper'

describe CampaignsController do
  context "/" do
    before(:all) do
      @campaign_with_banners = FactoryGirl.create(:campaign_with_banners)
    end
    
    it "returns a banner" do
      get :show, :id => @campaign_with_banners.id
      response.content_type.should == "image/png"
    end
  end
end
