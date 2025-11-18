class CreateSellerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :seller_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :is_broker, default: false, null: false
      t.boolean :premium_access, default: false, null: false
      t.integer :credits, default: 0, null: false
      t.integer :free_contacts_used, default: 0, null: false
      t.integer :free_contacts_limit, default: 4, null: false
      t.boolean :receive_signed_nda, default: true, null: false

      t.timestamps
    end
    
    add_index :seller_profiles, :is_broker
    add_index :seller_profiles, :premium_access
  end
end
