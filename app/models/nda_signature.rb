class NdaSignature < ApplicationRecord
  belongs_to :user
  belongs_to :listing, optional: true
  
  enum :signature_type, { platform_wide: 0, listing_specific: 1 }
  
  validates :user_id, presence: true
  validates :signature_type, presence: true
  validates :signed_at, presence: true
  validates :ip_address, presence: true
end
