source 'https://rubygems.org'
ruby '2.0.0'

# Use Sinatra
gem 'sinatra'

# Use HAML
gem 'haml'

# Use Rake
gem 'rake'

# Use Active Record
gem "sinatra-activerecord"
gem 'activerecord', '4.0.4' # Fixed on version 4.0.4, otherwise migrations may fail.

# Use postgresql as the database for Active Record
gem 'pg'

# Use thin as webserver
gem 'thin'

#Use Carrierwave for uploads
gem "carrierwave"

# Use fog for Amazon S3
gem 'fog'

# Use Redis for caching
gem "redis-objects"

# Use Tux as console
gem 'tux'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  # Gem used so the code wil automatically refreshedm when a file is saved.
  # Note: only works wil 'ruby app.rb', not with 'rackup'
  gem 'rerun'
end

group :test do
  gem "rspec"
  gem 'capybara'
  gem 'selenium-webdriver'
  gem "factory_girl"
  gem 'shoulda-matchers'
  gem "database_cleaner"
  gem "curb"
end