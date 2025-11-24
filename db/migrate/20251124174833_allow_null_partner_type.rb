class AllowNullPartnerType < ActiveRecord::Migration[8.0]
  def change
    change_column_null :partner_profiles, :partner_type, true
  end
end
