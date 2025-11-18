class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :profile, polymorphic: true, null: false
      
      t.string :stripe_subscription_id
      t.integer :plan_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'EUR', null: false
      t.integer :status, null: false
      t.datetime :period_start, null: false
      t.datetime :period_end, null: false
      t.datetime :cancelled_at

      t.timestamps
    end
    
    add_index :subscriptions, :stripe_subscription_id
    add_index :subscriptions, :status
    add_index :subscriptions, [:profile_type, :profile_id]
  end
end
