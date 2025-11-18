class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :favorites, [:buyer_profile_id, :listing_id], unique: true
  end
end
