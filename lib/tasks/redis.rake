namespace :redis do
  desc "Rbuild Redis for Campaigns"
  task :rebuild do
    # First flush Redis
    $redis.flushdb
    
    Campaign.find_each do |campaign|
      campaign.banners.each do |banner|
        banner.add_banner_to_redis
        banner.set_path_for_heroku
      end
      campaign.add_random_ratio_to_redis
    end
  end
end