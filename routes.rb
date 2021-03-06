before "/admin*" do
  # HTTP authentication
  # This is a very ugly hack to get the Capybara test of the admin-interface working.
  protected! if !settings.test?
end

get "/" do
  #HACK: A little ugly way to get the first banner ID from Redis.
  redirect "/campaigns/#{Campaign.banner_ids_from_redis.first[0]}"
end

# GET /campaigns/:id
get '/campaigns/:id' do
  session[params[:id]] = 
    Campaign.find_from_redis_by_id(params[:id]).get_banner_and_requests_made(session[params[:id]])
  banner_path = session[params[:id]][:current_banner_path]
  
  # Render imae from Heroku on AWS
  if heroku?
    @banner_path = banner_path
    haml :"campaigns/index", :layout => false
  else
    send_file banner_path, :disposition => "inline"
  end
end

# Admin routes
# GET /admin
get '/admin' do
  redirect "/admin/campaigns"
end

# GET /admin/campaigns
get '/admin/campaigns' do
  # For simplicity, no pagination is used.
  @campaigns = Campaign.all
  haml :"admin/campaigns/index"
end

# GET /admin/campaigns/new
get "/admin/campaigns/new" do
  @campaign = Campaign.new
  haml :"admin/campaigns/new"
end

# POST /admin/campaigns
post "/admin/campaigns" do
  @campaign = Campaign.new params[:campaign]
  if @campaign.save
    redirect "/admin/campaigns/#{@campaign.id}"
  else
    haml :"admin/campaigns/new"
  end
end

# GET /admin/campaigns/:id
get '/admin/campaigns/:id' do
  @campaign = Campaign.find params[:id]
  haml :"admin/campaigns/show"
end

# GET /admin/campaigns/:id/edit
get '/admin/campaigns/:id/edit' do
  @campaign = Campaign.find params[:id]
  haml :"admin/campaigns/edit"
end

# PUT /admin/campaigns/:id
put '/admin/campaigns/:id' do
  @campaign = Campaign.find params[:id]
  if @campaign.update_attributes params[:campaign]
    redirect "/admin/campaigns/#{@campaign.id}"
  else
    haml :"admin/campaigns/edit"
  end
end

# DELETE /admin/campaigns/:id
delete '/admin/campaigns/:id' do
  campaign = Campaign.find params[:id]
  campaign.destroy
  redirect "/admin/campaigns"
end

# GET /admin/campaign/:campaign_id/banners/new
get "/admin/campaigns/:campaign_id/banners/new" do
  @banner = Banner.new
  haml :"admin/banners/new"
end

# POST /admin/campaign/:campaign_id/banners
post "/admin/campaigns/:campaign_id/banners" do
  @banner = Banner.new params[:banner]
  if @banner.save
    redirect "/admin/campaigns/#{@banner.campaign.id}"
  else
    haml :"admin/banners/new"
  end
end

# DELETE /admin/campaign/:campaign_id/banners
delete "/admin/campaigns/:campaign_id/banners/:id" do
  banner = Banner.find params[:id]
  banner.destroy
  redirect "/admin/campaigns/#{params[:campaign_id]}"
end