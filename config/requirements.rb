require "sinatra/activerecord"
require "carrierwave"
require_relative "../app/models/campaign"
require_relative "../app/models/banner"
require_relative "session"

class AdvidiTest < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

# Determine whether we're on Heroku or not
if ENV["DATABASE_URL"].present?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  require_relative "database"
end