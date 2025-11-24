class CreateCreditPacks < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_packs do |t|
      t.string :name, null: false
      t.integer :credits_amount, null: false
      t.integer :price_cents, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    add_index :credit_packs, :active
  end
end
