class AddPaymentFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :stripe_customer_id, :string
    add_column :users, :credits_balance, :integer, default: 0, null: false
    
    add_index :users, :stripe_customer_id, unique: true
  end
end
