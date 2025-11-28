class AddNotificationPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notify_new_listings, :boolean, default: true
    add_column :users, :notify_messages, :boolean, default: true
    add_column :users, :notify_timer_alerts, :boolean, default: true
    add_column :users, :notify_new_contacts, :boolean, default: true
    add_column :users, :notify_seller_messages, :boolean, default: true
    add_column :users, :receive_signed_ndas, :boolean, default: true
    add_column :users, :notify_contact_requests, :boolean, default: true
    add_column :users, :notify_subscription_renewal, :boolean, default: true
  end
end
