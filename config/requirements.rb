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

# Determine whether we're on Heroku or not
if ENV["DATABASE_URL"].present?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  require_relative "database"
end

require_relative "settings"