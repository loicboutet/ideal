class DropSubscriptionWebhookLogs < ActiveRecord::Migration[8.0]
  def change
    drop_table :subscription_webhook_logs, if_exists: true
  end
end
