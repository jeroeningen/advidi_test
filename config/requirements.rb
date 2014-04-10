require "sinatra/activerecord"
require "carrierwave"

# Require the models
require_relative "../app/models/campaign"
require_relative "../app/models/banner"

# Require the helpers
require_relative "../app/helpers/main"

require_relative "session"

# Register ActiveRecord
class AdvidiTest < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

# Set the database connection for Heroku
if ENV["DATABASE_URL"].present?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  # Set the database connection on localhost
  require_relative "database"
end

# Set the Redis path for Heroku
$redis = Redis.new(url: ENV["REDISTOGO_URL"]) if ENV["REDISTOGO_URL"].present?

require_relative "settings"