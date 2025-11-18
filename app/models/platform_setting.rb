class PlatformSetting < ApplicationRecord
  belongs_to :updated_by, class_name: 'User', optional: true
  
  enum :setting_type, { string: 0, integer: 1, boolean: 2, json: 3, decimal: 4 }
  
  validates :setting_key, presence: true, uniqueness: true
  validates :setting_value, presence: true
  validates :setting_type, presence: true
  
  def self.get(key)
    find_by(setting_key: key)&.setting_value
  end
  
  def self.set(key, value, updated_by_user = nil)
    setting = find_or_initialize_by(setting_key: key)
    setting.setting_value = value.to_s
    setting.updated_by = updated_by_user
    setting.save
  end
end
