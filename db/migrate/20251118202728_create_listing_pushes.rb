class CreateListingPushes < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_pushes do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :seller_profile, null: false, foreign_key: true
      t.datetime :pushed_at

      t.timestamps
    end
  end
end
