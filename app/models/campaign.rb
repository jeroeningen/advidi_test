class Campaign < ActiveRecord::Base
  has_many :banners, :dependent => :destroy
  
  validates :name, :presence => true, :uniqueness => true
  validates :random_ratio, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  
  include Redis::Objects
  list :banner_ids_from_redis
  
  # Get all the banner ids from redis and convert it to integers
  def get_banner_ids_from_redis
    banner_ids_from_redis.map(&:to_i)
  end
  
  # Determine which type of request must be made and return a hash of requests made
  # This function assures the random_ratio for 100 requests
  #
  # For a more complex application it might be a good idea to move this function to a module. 
  # For simplicity, I kept this function in the model
  def request(requests_made)
    # initiate requests if blank
    requests_made[:random] = 0 if requests_made[:random].blank?
    requests_made[:weighted] = 0 if requests_made[:weighted].blank?
    
    # determine which request should be made
    if ((rand * 100) < random_ratio && requests_made[:random] < random_ratio) ||
      (100 - random_ratio) == requests_made[:weighted]
      requests_made[:random] += 1
      requests_made[:current_request] = :random
    else
      requests_made[:weighted] += 1
      requests_made[:current_request] = :weighted
    end
    
    requests_made
  end
  
  # Return a Hash containing the banners left, current banner and requests made
  def get_banner_and_requests_made banner_ids_left_and_requests_made
    #create  the requests_made hash if nott exists
    banner_ids_left_and_requests_made[:requests_made] = {} if banner_ids_left_and_requests_made[:requests_made].blank?
    
    # set the request ratio
    banner_ids_left_and_requests_made[:requests_made][:random_ratio] = random_ratio
    
    # initiate the current_banner_id
    current_banner_id = 0
    
    # get new banner ids if no banner ids left
    banner_ids_left = banner_ids_left_and_requests_made[:banner_ids_left] || get_banner_ids_from_redis
    banner_ids_left = get_banner_ids_from_redis if banner_ids_left.empty?
    
    # determine the request
    request = request(banner_ids_left_and_requests_made[:requests_made])
    
    # TODO: try to make this function faster
    case request[:current_request]
      when :random
        current_banner_id = banner_ids_left.uniq.sample
      when :weighted
        current_banner_id = banner_ids_left.sample
    end
    banner_ids_left.delete current_banner_id
    
    { :current_banner_id => current_banner_id,
      :requests_made => request,
      :banner_ids_left => banner_ids_left
    }
  end
  
  # TODO: Implement find, so it gets the objects from Redis. See: http://squarism.com/2013/05/04/using-redis-as-a-database/
end
