class Favorite < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :buyer_profile_id, uniqueness: { scope: :listing_id }
end
