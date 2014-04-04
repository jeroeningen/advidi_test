class Banner < ActiveRecord::Base
  belongs_to :campaign
  
  validates :weight, :numericality => {:greater_than => 0}
  
  include Redis::Objects
  hash_key :paths, :global => true
  hash_key :content_types, :global => true
  
  after_save :add_banner_id_to_redis
  after_destroy :delete_banner_id_from_redis
  
  has_attached_file :image
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  
  # Add the banner id to Redis for the campaign
  def add_banner_id_to_redis
    delete_banner_id_from_redis
    
    #Add the banner id to the other banner ids
    banner_ids_from_redis = case
      when campaign.get_banner_ids_from_redis.present? 
        then campaign.get_banner_ids_from_redis
      else
        []
    end
    weight.times do
      banner_ids_from_redis << self.id
    end
    
    #Add the banner ids to Redis as a value
    Campaign.banner_ids_from_redis[campaign_id] = banner_ids_from_redis.join(" ")
    
    Banner.paths[self.id] = image.path
    Banner.content_types[self.id] = image.content_type
  end
  
  #Delete the banner from Redis
  def delete_banner_id_from_redis
    if campaign.get_banner_ids_from_redis.present?
      banner_ids_from_redis = campaign.get_banner_ids_from_redis
      banner_ids_from_redis.delete self.id
      campaign.banner_ids_from_redis[campaign_id] = banner_ids_from_redis.join(" ")
    end
    
    Banner.paths.delete self.id
    Banner.content_types.delete self.id
  end
end
