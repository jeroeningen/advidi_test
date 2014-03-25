class CreateCampaigns < ActiveRecord::Migration
  def up
    create_table :campaigns do |t|
      t.string :name, :default => "", :null => false
      t.integer :random_ratio, :default => 0
      t.timestamps
    end
  end
  
  def down
    drop_table :campaigns
  end
end
