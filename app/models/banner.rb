require 'carrierwave/orm/activerecord'
require_relative "../uploaders/image_uploader"
class Banner < ActiveRecord::Base
  belongs_to :campaign
  
  validates :weight, :numericality => {:greater_than => 0}

  include Redis::Objects
  hash_key :paths, :global => true
  hash_key :content_types, :global => true
  
  after_save :add_banner_to_redis
  after_destroy :delete_banner_from_redis
  
  mount_uploader :image, ImageUploader
  
  # Add the banner to Redis for the campaign
  def add_banner_to_redis
    if campaign.present?
      delete_banner_from_redis
    
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
    
      # At this moment the image path is a temporary path.
      # The image path will be set in the callback 'after_commit'.
      # Setting the image path for Redis in the callback 'after_commit', 
      # may conflict with the callback 'after_destroy', where I delete the path from Redis.
      # so that's why I set it this way.
      Banner.paths[self.id] = "#{Dir.pwd}/public/#{image.store_path}"
      Banner.content_types[self.id] = image.content_type
    end
  end
  
  #Delete the banner from Redis
  def delete_banner_from_redis
    if campaign.present? && campaign.get_banner_ids_from_redis.present?
      banner_ids_from_redis = campaign.get_banner_ids_from_redis
      banner_ids_from_redis.delete self.id
      Campaign.banner_ids_from_redis[campaign_id] = banner_ids_from_redis.join(" ")
    end
    
    Banner.paths.delete self.id
    Banner.content_types.delete self.id
  end
end
