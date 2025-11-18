class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      
      t.integer :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.string :link_url
      t.boolean :read, default: false, null: false
      t.datetime :read_at
      t.boolean :sent_via_email, default: false, null: false

      t.timestamps
    end
    
    add_index :notifications, :notification_type
    add_index :notifications, :read
    add_index :notifications, :created_at
  end
end
