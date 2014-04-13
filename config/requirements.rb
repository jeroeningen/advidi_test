require "sinatra/activerecord"
require "carrierwave"

# Helper method for Heroku
require_relative "initializers/heroku"

# Set the config for AWS
require_relative "initializers/aws"

# Set the config for Redis
require_relative "initializers/redis"

# Require the models
require_relative "../app/models/campaign"
require_relative "../app/models/banner"

# Require the helpers
require_relative "../app/helpers/main"

# Use Rack::Session::Pool
require_relative "initializers/session"

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

require_relative "initializers/settings"