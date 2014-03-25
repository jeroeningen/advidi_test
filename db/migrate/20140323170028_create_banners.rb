class CreateBanners < ActiveRecord::Migration
  def up
    create_table :banners do |t|
      t.integer :campaign_id, :default => 0
      t.integer :weight, :default => 1
      t.timestamps
    end
    
    add_attachment :banners, :banner
    
    add_index :banners, :campaign_id
  end
  
  def down
    drop_table :banners
  end
end
