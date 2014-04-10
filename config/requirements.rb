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

# Upload files to S3 when on Heroku
if settings.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],      # required
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'], # required
    }
    config.fog_directory  = 'public/uploads'                   # required
  end
  
  #HACK: Global variable used in the uploader
  $environment = :production
end

require_relative "settings"