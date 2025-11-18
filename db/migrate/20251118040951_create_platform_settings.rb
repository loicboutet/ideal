class CreatePlatformSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :platform_settings do |t|
      t.string :setting_key, null: false
      t.text :setting_value, null: false
      t.integer :setting_type, null: false
      t.text :description
      t.references :updated_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :platform_settings, :setting_key, unique: true
  end
end
