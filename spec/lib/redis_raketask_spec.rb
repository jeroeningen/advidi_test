require 'spec_helper'

describe Redis do
  context "Raketasks" do
    before(:each) do
      @campaign = FactoryGirl.create(:redis_raketask_campaign)
      @banner = @campaign.banners.first
      Redis.current.flushdb
      system("RACK_ENV=test rake redis:rebuild")
    end
    it "'Rebuilds' Redis for campaigns" do
      @campaign.get_banner_ids_from_redis.should == @campaign.banner_ids
      @campaign.get_random_ratio_from_redis.should == @campaign.random_ratio
      Banner.paths[@banner.id].should == @banner.image.path
      Banner.content_types[@banner.id].should == @banner.image.content_type
    end
  end
end