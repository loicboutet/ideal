class CreateBuyerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :buyer_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      
      # Subscription
      t.integer :subscription_plan, default: 0, null: false
      t.integer :subscription_status, default: 0, null: false
      t.datetime :subscription_expires_at
      t.integer :credits, default: 0, null: false
      t.string :stripe_customer_id
      
      # Profile status
      t.boolean :verified_buyer, default: false, null: false
      t.integer :profile_status, default: 0, null: false
      t.integer :completeness_score, default: 0, null: false
      
      # Public data
      t.integer :buyer_type
      t.text :formation
      t.text :experience
      t.text :skills
      t.text :investment_thesis
      
      # Target criteria (stored as text for JSON)
      t.text :target_sectors
      t.text :target_locations
      t.decimal :target_revenue_min, precision: 15, scale: 2
      t.decimal :target_revenue_max, precision: 15, scale: 2
      t.integer :target_employees_min
      t.integer :target_employees_max
      t.integer :target_financial_health
      t.string :target_horizon
      t.text :target_transfer_types
      t.text :target_customer_types
      
      # Financial data
      t.decimal :investment_capacity, precision: 15, scale: 2
      t.text :funding_sources
      
      # Confidential data
      t.string :linkedin_url

      t.timestamps
    end
    
    add_index :buyer_profiles, :subscription_plan
    add_index :buyer_profiles, :subscription_status
    add_index :buyer_profiles, :stripe_customer_id
    add_index :buyer_profiles, :verified_buyer
    add_index :buyer_profiles, :profile_status
  end
end
