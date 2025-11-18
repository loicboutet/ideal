class ListingView < ApplicationRecord
  belongs_to :listing
  belongs_to :user, optional: true
  
  validates :listing_id, presence: true
  validates :viewed_at, presence: true
end
