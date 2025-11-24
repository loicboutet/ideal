class CreatePaymentTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "EUR", null: false
      t.string :status, null: false
      t.string :stripe_payment_intent_id
      t.string :transaction_type, null: false
      t.text :description
      t.text :metadata

      t.timestamps
    end
    
    add_index :payment_transactions, :stripe_payment_intent_id
    add_index :payment_transactions, :status
    add_index :payment_transactions, :transaction_type
    add_index :payment_transactions, :created_at
  end
end
