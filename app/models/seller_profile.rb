class SellerProfile < ApplicationRecord
  belongs_to :user
  
  has_many :listings, dependent: :destroy
  has_many :listing_pushes, dependent: :destroy
  has_many :credit_transactions, dependent: :destroy
  
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
  
  # New transaction-based credit methods
  def award_credits(amount, transaction_type, source: nil, description: nil)
    return false if amount <= 0
    
    transaction do
      increment!(:credits, amount)
      credit_transactions.create!(
        amount: amount,
        transaction_type: transaction_type,
        source: source,
        description: description,
        balance_after: credits
      )
    end
    
    true
  rescue => e
    Rails.logger.error "Failed to award credits: #{e.message}"
    false
  end
  
  def spend_credits(amount, transaction_type, source: nil, description: nil)
    return false if amount <= 0 || credits < amount
    
    transaction do
      decrement!(:credits, amount)
      credit_transactions.create!(
        amount: -amount,
        transaction_type: transaction_type,
        source: source,
        description: description,
        balance_after: credits
      )
    end
    
    true
  rescue => e
    Rails.logger.error "Failed to spend credits: #{e.message}"
    false
  end
  
  def transaction_history(limit: 50)
    credit_transactions.recent.limit(limit)
  end
  
  def total_earned
    credit_transactions.earned.sum(:amount)
  end
  
  def total_spent
    credit_transactions.spent.sum(:amount).abs
  end
  
  def credits_earned_this_month
    credit_transactions.earned.this_month.sum(:amount)
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
