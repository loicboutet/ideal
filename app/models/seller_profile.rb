class SellerProfile < ApplicationRecord
  belongs_to :user
  
  has_many :listings, dependent: :destroy
  has_many :listing_pushes, dependent: :destroy
  
  validates :user_id, presence: true, uniqueness: true
  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validates :free_contacts_used, numericality: { greater_than_or_equal_to: 0 }
  validates :free_contacts_limit, numericality: { greater_than_or_equal_to: 0 }
  
  # Instance methods
  def can_contact_buyer?
    premium_access || free_contacts_used < free_contacts_limit
  end
  
  def increment_contacts!
    increment!(:free_contacts_used) unless premium_access
  end
  
  def add_credits(amount)
    increment!(:credits, amount)
  end
  
  def deduct_credits(amount)
    return false if credits < amount
    decrement!(:credits, amount)
    true
  end
end
