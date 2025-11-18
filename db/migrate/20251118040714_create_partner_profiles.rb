class CreatePartnerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :partner_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      
      t.integer :partner_type, null: false
      t.text :description
      t.text :services_offered
      t.string :calendar_link
      t.string :website
      t.integer :coverage_area
      t.text :coverage_details
      t.text :intervention_stages
      t.text :industry_specializations
      t.integer :validation_status, default: 0, null: false
      t.datetime :directory_subscription_expires_at
      t.integer :views_count, default: 0, null: false
      t.integer :contacts_count, default: 0, null: false
      t.string :stripe_customer_id

      t.timestamps
    end
    
    add_index :partner_profiles, :partner_type
    add_index :partner_profiles, :validation_status
    add_index :partner_profiles, :coverage_area
    add_index :partner_profiles, :stripe_customer_id
  end
end
