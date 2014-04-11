# FIXME: Sinatra must be required here, because otherwise the banner_paths in Redis are set wrong 
# in the function Campaign.add_banner_to_redis.
# This is because of the usage of 'Dir#pwd' which otherwise will return the 'config-path' instead of the rot path..
require 'sinatra'
require_relative "config/requirements"

# In Rails this should be added to the config-dir
# Because a lot of 'controller-logic' is inside the routes, I decided to add it to the root-directory
require_relative "routes"