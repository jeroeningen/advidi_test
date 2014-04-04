class CampaignsController < ApplicationController
  def show
    session[:banner_and_requests_made] = Campaign.find_from_redis_by_id(params[:id]).get_banner_and_requests_made session[:banner_and_requests_made]
    send_file session[:banner_and_requests_made][:current_banner_path], type: session[:banner_and_requests_made][:current_banner_content_type], :disposition => "inline"
  end
end
