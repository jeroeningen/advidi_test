require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'sinatra'
require 'rack/test'
require 'shoulda/matchers'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
set :database, {:adapter => "postgresql", :database => "advidi_test", :username => "stiptomedia_program"}

def app
  Sinatra::Application
end

require 'database_cleaner'

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # config.use_transactional_fixtures = true
  DatabaseCleaner.strategy = :truncation
  
  DatabaseCleaner.clean

  # config.infer_base_class_for_anonymous_controllers = false

  config.order = "random"

  require 'factory_girl'
  Dir[Dir.pwd + "/spec/factories/**/*.rb"].each {|f| require f}
end
