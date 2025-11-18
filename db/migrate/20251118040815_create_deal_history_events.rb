class CreateDealHistoryEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :deal_history_events do |t|
      t.references :deal, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      
      t.integer :event_type, null: false
      t.integer :from_status
      t.integer :to_status
      t.text :notes

      t.timestamps
    end
    
    add_index :deal_history_events, :event_type
    add_index :deal_history_events, :created_at
  end
end
