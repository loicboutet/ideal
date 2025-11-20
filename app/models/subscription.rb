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
  
  # Scopes
  scope :active_subscriptions, -> { where(status: :active) }
  scope :buyer_subscriptions, -> { where(plan_type: [:buyer_starter, :buyer_standard, :buyer_premium, :buyer_club]) }
  scope :seller_subscriptions, -> { where(plan_type: :seller_premium) }
  scope :partner_subscriptions, -> { where(plan_type: :partner_directory) }
  scope :expiring_soon, -> { where('period_end < ?', 7.days.from_now).active_subscriptions }
  
  # Status check methods
  def active?
    status == 'active' && !expired?
  end
  
  def cancelled?
    status == 'cancelled' || cancel_at_period_end?
  end
  
  def will_renew?
    active? && !cancel_at_period_end?
  end
  
  def expired?
    return false unless period_end
    
    period_end < Time.current
  end
  
  def in_grace_period?
    return false unless period_end
    
    expired? && period_end > 3.days.ago
  end
  
  # Time-related methods
  def days_until_renewal
    return nil unless period_end && active?
    
    ((period_end - Time.current) / 1.day).ceil
  end
  
  def days_until_expiry
    days_until_renewal
  end
  
  def renewal_date
    period_end
  end
  
  # Plan details methods
  def plan_config
    return nil unless user
    
    role = determine_role
    plan_key = plan_type_to_key
    
    SubscriptionPlans.plan_details(role, plan_key)
  end
  
  def plan_name
    plan_config&.dig(:name) || plan_type.titleize
  end
  
  def plan_price_display
    plan_config&.dig(:price_display) || format_amount
  end
  
  def plan_features
    plan_config&.dig(:features) || []
  end
  
  def plan_limits
    plan_config&.dig(:limits) || {}
  end
  
  def plan_interval
    plan_config&.dig(:interval) || 'month'
  end
  
  # Feature access methods
  def has_feature?(feature)
    return false unless plan_config
    
    SubscriptionPlans.plan_has_feature?(determine_role, plan_type_to_key, feature)
  end
  
  def feature_limit(feature)
    return 0 unless plan_config
    
    SubscriptionPlans.plan_feature_limit(determine_role, plan_type_to_key, feature)
  end
  
  def can_access_feature?(feature)
    active? && has_feature?(feature)
  end
  
  # Amount formatting
  def format_amount
    return '€0' if amount.nil? || amount.zero?
    
    "€#{(amount / 100.0).round(2)}"
  end
  
  def amount_in_euros
    return 0 if amount.nil?
    
    (amount / 100.0).round(2)
  end
  
  # Stripe integration helpers
  def stripe_subscription_url
    return nil unless stripe_subscription_id
    
    if Rails.env.production?
      "https://dashboard.stripe.com/subscriptions/#{stripe_subscription_id}"
    else
      "https://dashboard.stripe.com/test/subscriptions/#{stripe_subscription_id}"
    end
  end
  
  # Renewal status
  def renewal_status_text
    return 'Expired' if expired?
    return 'Cancelled - Active until end of period' if cancelled?
    return 'Active - Renews automatically' if will_renew?
    
    'Active'
  end
  
  # Check if subscription needs attention (expiring soon, cancelled, etc.)
  def needs_attention?
    cancelled? || (days_until_renewal && days_until_renewal < 7)
  end
  
  private
  
  def determine_role
    # Determine role based on plan_type or profile
    if buyer_plan?
      :buyer
    elsif seller_plan?
      :seller
    elsif partner_plan?
      :partner
    else
      # Fallback to user's role if we can't determine from plan
      user&.role&.to_sym
    end
  end
  
  def buyer_plan?
    plan_type.to_s.start_with?('buyer_')
  end
  
  def seller_plan?
    plan_type.to_s.start_with?('seller_')
  end
  
  def partner_plan?
    plan_type.to_s.start_with?('partner_')
  end
  
  def plan_type_to_key
    # Convert enum plan_type to subscription plan key
    # e.g., 'buyer_starter' -> :starter, 'seller_premium' -> :premium
    case plan_type.to_s
    when 'buyer_starter' then :starter
    when 'buyer_standard' then :standard
    when 'buyer_premium' then :premium
    when 'buyer_club' then :club
    when 'seller_premium' then :premium
    when 'partner_directory' then :annual
    else
      plan_type.to_sym
    end
  end
end
