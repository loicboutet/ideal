class BuyerProfile < ApplicationRecord
  belongs_to :user
  
  has_many :deals, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :enrichments, dependent: :destroy
  has_many :listing_pushes, dependent: :destroy
  
  # Enums
  enum :subscription_plan, { free: 0, starter: 1, standard: 2, premium: 3, club: 4 }
  enum :subscription_status, { inactive: 0, active: 1, cancelled: 2, expired: 3 }
  enum :profile_status, { draft: 0, pending: 1, published: 2 }
  enum :buyer_type, { individual: 0, holding: 1, fund: 2, investor: 3 }
  enum :target_financial_health, { in_bonis: 0, in_difficulty: 1, both: 2 }
  
  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :credits, numericality: { greater_than_or_equal_to: 0 }
  validates :completeness_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  # Serialization for JSON fields
  serialize :target_sectors, type: Array, coder: JSON
  serialize :target_locations, type: Array, coder: JSON
  serialize :target_transfer_types, type: Array, coder: JSON
  serialize :target_customer_types, type: Array, coder: JSON
  
  # Scopes
  scope :verified, -> { where(verified_buyer: true) }
  scope :active_subscribers, -> { where(subscription_status: :active) }
  scope :published_profiles, -> { where(profile_status: :published) }
  
  # Instance methods
  def subscription_active?
    subscription_status == 'active' && (subscription_expires_at.nil? || subscription_expires_at > Time.current)
  end
  
  def add_credits(amount)
    increment!(:credits, amount)
  end
  
  def deduct_credits(amount)
    return false if credits < amount
    decrement!(:credits, amount)
    true
  end
  
  def can_access_listing?
    subscription_plan != 'free' && subscription_active?
  end
  
  def calculate_completeness
    score = 0
    total_fields = 15
    
    # Public fields
    score += 1 if buyer_type.present?
    score += 1 if formation.present?
    score += 1 if experience.present?
    score += 1 if skills.present?
    score += 1 if investment_thesis.present?
    score += 1 if target_sectors.present? && target_sectors.any?
    score += 1 if target_locations.present? && target_locations.any?
    score += 1 if target_revenue_min.present?
    score += 1 if target_revenue_max.present?
    score += 1 if target_employees_min.present?
    score += 1 if target_employees_max.present?
    score += 1 if target_financial_health.present?
    score += 1 if target_horizon.present?
    score += 1 if investment_capacity.present?
    score += 1 if funding_sources.present?
    
    ((score.to_f / total_fields) * 100).round
  end
  
  def update_completeness!
    update(completeness_score: calculate_completeness)
  end
end
