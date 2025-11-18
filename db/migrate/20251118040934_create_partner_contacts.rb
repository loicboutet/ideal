class CreatePartnerContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :partner_contacts do |t|
      t.references :partner_profile, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.integer :contact_type, null: false

      t.timestamps
    end
    
    add_index :partner_contacts, :contact_type
    add_index :partner_contacts, :created_at
  end
end
