class CreateLeadImports < ActiveRecord::Migration[8.0]
  def change
    create_table :lead_imports do |t|
      t.references :imported_by, null: false, foreign_key: { to_table: :users }
      
      t.string :file_name, null: false
      t.integer :total_rows, null: false
      t.integer :successful_imports, default: 0, null: false
      t.integer :failed_imports, default: 0, null: false
      t.integer :import_status, default: 0, null: false
      t.text :error_log
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :lead_imports, :import_status
  end
end
