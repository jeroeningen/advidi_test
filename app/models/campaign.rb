require 'redis-objects'
class Campaign < ActiveRecord::Base
  has_many :banners, :dependent => :destroy
  
  validates :name, :presence => true, :uniqueness => true
  validates :random_ratio, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  
  include Redis::Objects
  
  hash_key :banner_ids_from_redis, :global => true
  hash_key :random_ratio_from_redis, :global => true 
  
  after_save :add_random_ratio_to_redis
  after_destroy :delete_random_ratio_from_redis
  
  # Add the random ratio to Redis
  def add_random_ratio_to_redis
    self.random_ratio_from_redis[self.id] = random_ratio
  end
  
  # Delete the random ratio from Redis
  def delete_random_ratio_from_redis
    self.random_ratio_from_redis.delete self.id
  end
  
  # Set the Campaign ID so the attributes can be retrieved from the Redis hash keys
  # This function is inspired by the following article: http://squarism.com/2013/05/04/using-redis-as-a-database/
  def self.find_from_redis_by_id id
    campaign = new(:id => id, :random_ratio => random_ratio_from_redis[id])
    
    if campaign.get_banner_ids_from_redis.present? && campaign.get_random_ratio_from_redis.present?
      campaign
    end
  end
  
  # Get all the banner ids from redis and convert it to integers
  def get_banner_ids_from_redis
    if self.banner_ids_from_redis[self.id].present?
      banner_ids_string = self.banner_ids_from_redis[self.id]
      banner_ids_string.split(" ").map(&:to_i)
    end
  end
  
  # Get the random ratio from redis and convert it to integers
  def get_random_ratio_from_redis
    if self.random_ratio_from_redis[self.id].present?
      self.random_ratio_from_redis[self.id].to_i
    end
  end
  
  # Determine which type of request must be made and return a hash of requests made
  # This function assures the random_ratio for as minimum requests as possible
  #
  # For a more complex application it might be a good idea to move this function to a module. 
  # For simplicity, I kept this function in the model
  def request(requests_made)
    # initiate requests_made if blank
    requests_made[:random] = 0 if requests_made[:random].blank?
    requests_made[:weighted] = 0 if requests_made[:weighted].blank?
    
    # Determine the number of requests to be made, before we must start over with counting
    if requests_made[:common_denominator].blank?
      requests_made[:common_denominator] = case 
        when [0, 100].include?(random_ratio) then 1
        # determine the highest common denominator
        else 50.downto(2).find {|i| random_ratio % i == 0 && (100 - random_ratio) % i == 0}
      end
    end
    
    # determine which request should be made
    if ((rand * 100) < random_ratio && requests_made[:random] < (random_ratio / requests_made[:common_denominator])) ||
      ((100 - random_ratio) / requests_made[:common_denominator]) == requests_made[:weighted]
      requests_made[:random] += 1
      requests_made[:current_request] = :random
    else
      requests_made[:weighted] += 1
      requests_made[:current_request] = :weighted
    end
    
    requests_made
  end
  
  # Return a Hash containing the banners left, current banner and requests made
  def get_banner_and_requests_made banner_and_requests_made
    # initiate the hash 'banner_and_requests_made' if not exists. Needed for the first request
    banner_and_requests_made = {} if banner_and_requests_made.blank?
    
    #create the requests_made hash if not exists. Needed for the first request.
    banner_and_requests_made[:requests_made] = {} if banner_and_requests_made[:requests_made].blank?
    
    # initiate the current_banner_id
    current_banner_id = 0
    
    # get new banner ids if no banner ids left
    banner_ids_left = banner_and_requests_made[:banner_ids_left]
    banner_ids_left = get_banner_ids_from_redis if banner_ids_left.blank? || banner_ids_left.empty?
    
    # determine the request
    request = request(banner_and_requests_made[:requests_made])
    
    # TODO: try to make this function faster
    case request[:current_request]
      when :random
        current_banner_id = banner_ids_left.uniq.sample
      when :weighted
        current_banner_id = banner_ids_left.sample
    end
    banner_ids_left.delete current_banner_id
    
    { :current_banner_id => current_banner_id,
      :current_banner_path => Banner.paths[current_banner_id],
      :current_banner_content_type => Banner.content_types[current_banner_id],
      :requests_made => request,
      :banner_ids_left => banner_ids_left
    }
  end
end
