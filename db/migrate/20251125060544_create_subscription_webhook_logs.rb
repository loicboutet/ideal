class CreateSubscriptionWebhookLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_webhook_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.string :subscription_id
      t.text :payload
      t.string :status, null: false, default: 'pending'
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end
    
    add_index :subscription_webhook_logs, :event_id, unique: true
    add_index :subscription_webhook_logs, :event_type
    add_index :subscription_webhook_logs, :status
    add_index :subscription_webhook_logs, :created_at
  end
end
