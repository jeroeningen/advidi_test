require 'carrierwave/orm/activerecord'
require_relative "../uploaders/image_uploader"
class Banner < ActiveRecord::Base
  belongs_to :campaign
  
  validates :weight, :numericality => {:greater_than => 0}

  include Redis::Objects
  
  # TODO 'image_paths' may be a better name then 'paths'
  hash_key :paths, :global => true
  
  after_save :add_banner_to_redis
  after_commit :set_path_for_heroku
  after_destroy :delete_banner_from_redis
  
  mount_uploader :image, ImageUploader
  
  # Add the banner to Redis for the campaign
  def add_banner_to_redis
    if campaign.present?
      delete_banner_from_redis
      
      banner_ids_from_redis = case
        when campaign.get_banner_ids_from_redis.present? 
          then campaign.get_banner_ids_from_redis
        else
          []
      end
      #Add the banner id to the other banner ids
      weight.times do
        banner_ids_from_redis << self.id
      end
      
      #Add the banner ids to Redis as a value
      Campaign.banner_ids_from_redis[campaign_id] = banner_ids_from_redis.join(" ")
      
      # Development:
      # At this moment the image path is a temporary path, 
      # moreover Carrierwave does not always set all attibutes right at this point
      # So I set the image path in a little strange way, to be sure, the path is always set right.
      # HACK: If we're on Heroku, set the path in the 'after_commit' callback
      if !heroku?
        Banner.paths[self.id] = "#{Dir.pwd}/public/#{image.store_dir}/#{image.file.present? ? image.file.filename : image.filename}"
      end
    end
  end
  
  # HACK: Because in the after_save callback, I can only get the 'tmp_url' as image.url for an Amazon S3 upload,
  # I set the right URL in the fter_commit callback for Heroku
  def set_path_for_heroku
    if !destroyed? && heroku?
      Banner.paths[self.id] = image.url
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
  end
end
