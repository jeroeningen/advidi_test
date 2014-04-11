require 'redis-objects'

# Set the Redis path for Heroku
$redis = Redis.new(url: ENV["REDISTOGO_URL"]) if ENV["REDISTOGO_URL"].present?
