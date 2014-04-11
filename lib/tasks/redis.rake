# HACK: Set Redis here, otherwise the 'Raketask' will fail
# Set the Redis path for Heroku
$redis = Redis.new(url: ENV["REDISTOGO_URL"]) if ENV["REDISTOGO_URL"].present?

namespace :redis do
  desc "Rbuild Redis for Campaigns"
  task :rebuild do
    # First flush Redis
    Redis.current.flushdb
    
    Campaign.find_each do |campaign|
      campaign.banners.each do |banner|
        banner.add_banner_to_redis
      end
      campaign.add_random_ratio_to_redis
    end
  end
end