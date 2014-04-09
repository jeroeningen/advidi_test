require 'spec_helper'

describe "Admin" do
  before(:each) do
    @campaign_with_two_banners = FactoryGirl.create(:campaign_with_two_banners)
  end
  
  # FIXME This test fails if runned combined with all the rspec-tests
  context "/" do
    it "is not protected with HTTP authentication" do
      get "/campaigns/#{@campaign_with_two_banners.id}"
      last_response.status.should == 200
    end
  end
  
  # HTTP authentication is disabled in the test-environment, because Capybara can't handle it
  pending "/admin" do
    it "is protected with HTTP authentication" do
      get "/admin"
      last_response.status.should == 401
    end
    
    it "has the user 'advidi' and the password 'advidi'" do
      authorize "advidi", "advidi"
      get "/admin"
      last_response.status.should == 200
    end
  end
end
