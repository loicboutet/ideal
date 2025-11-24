class CreateAdminMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_messages do |t|
      t.integer :sent_by_id, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :message_type, default: 0, null: false
      t.integer :target_role, default: 0, null: false
      t.boolean :send_email, default: true
      t.boolean :show_in_dashboard, default: true
      t.datetime :sent_at
      t.integer :recipients_count, default: 0

      t.timestamps
    end
    
    add_index :admin_messages, :sent_by_id
    add_index :admin_messages, :message_type
    add_index :admin_messages, :sent_at
    add_foreign_key :admin_messages, :users, column: :sent_by_id
  end
end
