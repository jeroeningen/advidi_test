require 'redis-objects'

# Set the Redis path for Heroku
$redis = case
  when ENV["REDISTOGO_URL"].present? then Redis.new(url: ENV["REDISTOGO_URL"])
  else Redis.new
end