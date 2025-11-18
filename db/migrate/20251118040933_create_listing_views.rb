class CreateListingViews < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_views do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      
      t.string :ip_address
      t.datetime :viewed_at, null: false

      t.timestamps
    end
    
    add_index :listing_views, :viewed_at
    add_index :listing_views, [:listing_id, :user_id]
  end
end
