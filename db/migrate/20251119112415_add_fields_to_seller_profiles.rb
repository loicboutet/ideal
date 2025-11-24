class AddFieldsToSellerProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :seller_profiles, :siret_number, :string
    add_column :seller_profiles, :specialization, :text
    add_column :seller_profiles, :intervention_zones, :text
    add_column :seller_profiles, :specialization_sectors, :text
    add_column :seller_profiles, :intervention_stages, :text
    add_column :seller_profiles, :calendar_link, :string
    add_column :seller_profiles, :profile_views_count, :integer, default: 0, null: false
    add_column :seller_profiles, :profile_contacts_count, :integer, default: 0, null: false
  end
end
