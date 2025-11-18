class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: true, foreign_key: true
      t.references :trackable, polymorphic: true, null: true
      
      t.integer :action_type, null: false
      t.json :metadata
      t.string :ip_address

      t.timestamps
    end
    
    add_index :activities, :action_type
    add_index :activities, :created_at
    add_index :activities, [:trackable_type, :trackable_id]
  end
end
