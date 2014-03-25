class Banner < ActiveRecord::Base
  belongs_to :campaign
  
  validates :weight, :numericality => {:greater_than => 0}
  
  after_save :add_banner_id_to_redis
  after_destroy :delete_banner_id_from_redis
  
  def add_banner_id_to_redis
    delete_banner_id_from_redis
    weight.times do
      campaign.banner_ids_from_redis << self.id
    end
  end
  
  def delete_banner_id_from_redis
    campaign.banner_ids_from_redis.delete self.id
  end
end
