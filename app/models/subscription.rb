class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :profile, polymorphic: true
  
  enum :plan_type, {
    seller_premium: 0, buyer_starter: 1, buyer_standard: 2,
    buyer_premium: 3, buyer_club: 4, partner_directory: 5,
    credit_pack_small: 6, credit_pack_medium: 7, credit_pack_large: 8
  }
  enum :status, { pending: 0, active: 1, cancelled: 2, expired: 3, failed: 4 }
  
  validates :user_id, presence: true
  validates :plan_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
end
