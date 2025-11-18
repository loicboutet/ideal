class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      
      t.text :body, null: false
      t.boolean :read, default: false, null: false
      t.datetime :read_at

      t.timestamps
    end
    
    add_index :messages, :read
    add_index :messages, :created_at
  end
end
