class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.references :seller_profile, null: false, foreign_key: true
      t.references :attributed_buyer, foreign_key: { to_table: :buyer_profiles }, null: true
      
      # Deal type and status
      t.integer :deal_type, default: 0, null: false
      t.integer :validation_status, default: 0, null: false
      t.integer :status, default: 0, null: false
      
      # Public data
      t.string :title, null: false
      t.text :description_public
      t.integer :industry_sector, null: false
      t.string :location_department
      t.string :location_region
      t.string :location_country, default: 'France'
      
      # Confidential data
      t.text :description_confidential
      t.string :location_city
      t.string :website
      
      # Financial data
      t.decimal :annual_revenue, precision: 15, scale: 2
      t.integer :employee_count
      t.decimal :net_profit, precision: 15, scale: 2
      t.decimal :asking_price, precision: 15, scale: 2
      t.decimal :price_min, precision: 15, scale: 2
      t.decimal :price_max, precision: 15, scale: 2
      t.decimal :net_revenue_ratio, precision: 5, scale: 2
      
      # Business details
      t.string :transfer_horizon
      t.integer :transfer_type
      t.integer :company_age
      t.integer :customer_type
      t.string :legal_form
      
      # Scoring
      t.boolean :show_scorecard_stars, default: false, null: false
      t.integer :scorecard_stars
      t.integer :completeness_score, default: 0, null: false
      
      # Tracking
      t.integer :views_count, default: 0, null: false
      t.datetime :published_at

      t.timestamps
    end
    
    add_index :listings, :deal_type
    add_index :listings, :validation_status
    add_index :listings, :status
    add_index :listings, :industry_sector
    add_index :listings, :location_department
    add_index :listings, :published_at
    add_index :listings, [:seller_profile_id, :status]
  end
end
