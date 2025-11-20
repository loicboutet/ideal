class CreateCreditTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_transactions do |t|
      t.references :seller_profile, null: false, foreign_key: true
      t.integer :amount, null: false
      t.integer :transaction_type, null: false
      t.string :source_type
      t.integer :source_id
      t.text :description
      t.integer :balance_after, null: false

      t.timestamps
    end
    
    add_index :credit_transactions, [:source_type, :source_id]
    add_index :credit_transactions, :transaction_type
    add_index :credit_transactions, :created_at
  end
end
