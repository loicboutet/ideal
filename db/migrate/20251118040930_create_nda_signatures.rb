class CreateNdaSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :nda_signatures do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: true, foreign_key: true
      
      t.integer :signature_type, null: false
      t.datetime :signed_at, null: false
      t.string :ip_address, null: false
      t.string :user_agent
      t.boolean :accepted_terms, default: true, null: false

      t.timestamps
    end
    
    add_index :nda_signatures, :signature_type
    add_index :nda_signatures, :signed_at
    add_index :nda_signatures, [:user_id, :listing_id]
  end
end
