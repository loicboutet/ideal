class SellerProfile < ApplicationRecord
  belongs_to :user
  
  has_many :listings, dependent: :destroy
  has_many :listing_pushes, dependent: :destroy
  
  validates :user_id, presence: true, uniqueness: true
  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validates :free_contacts_used, numericality: { greater_than_or_equal_to: 0 }
  validates :free_contacts_limit, numericality: { greater_than_or_equal_to: 0 }
  
  # Serialize JSON fields
  serialize :intervention_zones, coder: JSON
  serialize :specialization_sectors, coder: JSON
  serialize :intervention_stages, coder: JSON
  
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
  
  # Statistics helper methods
  def active_mandates_count
    listings.where(deal_type: [:ideal_mandate, :partner_mandate], status: [:active, :pending]).count
  end
  
  def total_listings_count
    listings.count
  end
  
  def monthly_pushes_count
    listing_pushes.where('pushed_at >= ?', 30.days.ago).count
  end
end
