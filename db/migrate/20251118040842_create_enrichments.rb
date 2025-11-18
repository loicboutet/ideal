class CreateEnrichments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrichments do |t|
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.references :validated_by, null: true, foreign_key: { to_table: :users }
      
      t.integer :document_category, null: false
      t.text :description
      t.integer :credits_awarded, default: 0, null: false
      t.boolean :validated, default: false, null: false
      t.datetime :validated_at

      t.timestamps
    end
    
    add_index :enrichments, :validated
    add_index :enrichments, [:listing_id, :buyer_profile_id]
  end
end
