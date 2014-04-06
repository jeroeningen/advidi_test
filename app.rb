# FIXME: Sinatra must be required here, because otherwise the banner_paths in Redis are set wrong 
# in the function Campaign.add_banner_to_redis.
# This is because of the usage of 'Dir#pwd' which otherwise will return the 'config-path' instead of the rot path..
require 'sinatra'
require_relative "config/requirements"

get '/campaigns/:id' do
  session[:banner_and_requests_made] = 
    Campaign.find_from_redis_by_id(params[:id]).get_banner_and_requests_made(session[:banner_and_requests_made])
  banner_path = session[:banner_and_requests_made][:current_banner_path]
  content_type = session[:banner_and_requests_made][:current_banner_content_type]
  send_file banner_path, type: content_type, :disposition => "inline"
end