class AddValidationFieldsToListings < ActiveRecord::Migration[8.0]
  def change
    add_column :listings, :submitted_at, :datetime
    add_column :listings, :validated_at, :datetime
    add_column :listings, :rejection_reason, :text
    add_column :listings, :validation_notes, :text
  end
end
