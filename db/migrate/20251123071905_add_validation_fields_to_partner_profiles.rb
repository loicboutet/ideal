class AddValidationFieldsToPartnerProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :partner_profiles, :validated_at, :datetime
    add_column :partner_profiles, :rejection_reason, :text
  end
end
