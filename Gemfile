source 'https://rubygems.org'

# Use Sinatra
gem 'sinatra'

# Use Active Record
gem "sinatra-activerecord"

# Use postgresql as the database for Active Record
gem 'pg'

# Sinatra console
gem "tux"

# Use thin as webserver
gem 'thin'

gem "carrierwave"

gem "redis-objects"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'rerun'
end

group :test do
  gem "rspec"
  gem "factory_girl"
  gem 'shoulda-matchers'
  gem "database_cleaner"
  gem "curb"
end