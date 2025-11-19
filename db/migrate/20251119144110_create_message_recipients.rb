class CreateMessageRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :message_recipients do |t|
      t.references :admin_message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :read, default: false, null: false
      t.datetime :read_at
      t.boolean :email_sent, default: false, null: false
      t.datetime :email_sent_at

      t.timestamps
    end
    
    add_index :message_recipients, [:user_id, :read], where: "read = false"
    add_index :message_recipients, [:admin_message_id, :user_id], unique: true
  end
end
