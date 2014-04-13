# Authentication
helpers do
  # do HTTP authentication
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end
  
  # Check whether the user is authorized
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && 
      @auth.basic? && 
      @auth.credentials &&
      @auth.credentials == ['advidi', 'advidi']
  end
end
