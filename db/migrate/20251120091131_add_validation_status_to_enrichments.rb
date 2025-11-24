class AddValidationStatusToEnrichments < ActiveRecord::Migration[8.0]
  def change
    add_column :enrichments, :validation_status, :integer, default: 0, null: false
    add_column :enrichments, :rejection_reason, :text
    
    add_index :enrichments, :validation_status
  end
end
