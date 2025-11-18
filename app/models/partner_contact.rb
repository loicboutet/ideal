class PartnerContact < ApplicationRecord
  belongs_to :partner_profile
  belongs_to :user
  
  enum :contact_type, { view: 0, contact: 1 }
  
  validates :partner_profile_id, presence: true
  validates :user_id, presence: true
  validates :contact_type, presence: true
end
