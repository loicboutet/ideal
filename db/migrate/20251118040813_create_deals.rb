class CreateDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :deals do |t|
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      
      # CRM status (10 stages)
      t.integer :status, default: 0, null: false
      
      # Reservation
      t.boolean :reserved, default: false, null: false
      t.datetime :reserved_at
      t.datetime :reserved_until
      
      # Timing
      t.datetime :stage_entered_at
      t.integer :time_in_stage, default: 0, null: false
      
      # Credits and validation
      t.integer :total_credits_earned, default: 0, null: false
      t.boolean :loi_seller_validated, default: false, null: false
      
      # Notes and release
      t.text :notes
      t.datetime :released_at
      t.text :release_reason

      t.timestamps
    end
    
    add_index :deals, :status
    add_index :deals, :reserved
    add_index :deals, [:buyer_profile_id, :listing_id], unique: true, where: "released_at IS NULL"
    add_index :deals, :reserved_until
  end
end
