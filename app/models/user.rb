class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Enums
  enum :role, { admin: 0, seller: 1, buyer: 2, partner: 3 }
  enum :status, { pending: 0, active: 1, suspended: 2 }

  # Associations
  has_one :seller_profile, dependent: :destroy
  has_one :buyer_profile, dependent: :destroy
  has_one :partner_profile, dependent: :destroy
  
  has_many :nda_signatures, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :messages, through: :conversations
  has_many :notifications, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :activities, dependent: :nullify
  
  # Admin messaging system
  has_many :sent_admin_messages, class_name: 'AdminMessage', foreign_key: 'sent_by_id', dependent: :destroy
  has_many :message_recipients, dependent: :destroy
  has_many :received_admin_messages, through: :message_recipients, source: :admin_message
  has_many :survey_responses, dependent: :destroy
  
  # Validations
  validates :role, presence: true
  validates :status, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # Callbacks
  after_create :create_profile
  
  # Virtual attributes for registration
  attr_accessor :buyer_type, :partner_type
  
  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :sellers, -> { where(role: :seller) }
  scope :buyers, -> { where(role: :buyer) }
  scope :partners, -> { where(role: :partner) }
  scope :active_users, -> { where(status: :active) }
  
  # Instance Methods
  def full_name
    [first_name, last_name].compact.join(' ').presence || email
  end
  
  # Subscription & Payment Methods
  def current_subscription
    @current_subscription ||= subscriptions.where(status: ['active', 'trialing'])
                                          .order(created_at: :desc)
                                          .first
  end
  
  def subscription_active?
    current_subscription.present? && 
      ['active', 'trialing'].include?(current_subscription.status)
  end
  
  def subscription_plan
    return :free unless subscription_active?
    current_subscription.plan_type.to_sym
  end
  
  def has_plan?(plan_name)
    subscription_plan == plan_name.to_sym
  end
  
  def can_access_feature?(feature_name)
    plan = subscription_plan
    SubscriptionPlans.plan_has_feature?(role, plan, feature_name)
  end
  
  def subscription_level
    return 'free' unless subscription_active?
    current_subscription.plan_type
  end
  
  def feature_limit(feature_name)
    plan = subscription_plan
    SubscriptionPlans.plan_feature_limit(role, plan, feature_name)
  end
  
  def within_limit?(feature_name, current_count)
    limit = feature_limit(feature_name)
    return true if limit.nil? || limit == 999 # Unlimited
    return false if limit == 0
    
    current_count < limit
  end
  
  # Credit Methods
  def credits_balance
    read_attribute(:credits_balance) || 0
  end
  
  def has_sufficient_credits?(amount)
    credits_balance >= amount
  end
  
  def can_push_listing?
    return true if seller? && has_plan?(:premium)
    
    # Check monthly quota for premium sellers
    if seller? && has_plan?(:premium)
      monthly_pushes = listing_pushes.where('created_at >= ?', Time.current.beginning_of_month).count
      limit = feature_limit(:push_quota_per_month)
      return monthly_pushes < limit if limit
    end
    
    # Otherwise check credits
    has_sufficient_credits?(1)
  end
  
  def can_contact_partner?
    # Free for first 6 months if premium seller
    if seller? && has_plan?(:premium)
      subscription_age_months = (Time.current - current_subscription.period_start) / 1.month
      return true if subscription_age_months < 6
    end
    
    # Otherwise requires 5 credits
    has_sufficient_credits?(5)
  end
  
  def listing_pushes
    return ListingPush.none unless seller?
    ListingPush.joins(:listing).where(listings: { user_id: id })
  end
  
  def profile
    case role
    when 'seller'
      seller_profile
    when 'buyer'
      buyer_profile
    when 'partner'
      partner_profile
    else
      nil
    end
  end
  
  def unread_admin_messages_count
    message_recipients.unread.count
  end
  
  def unread_conversations_count
    # Force a fresh query to get accurate unread count
    # Don't rely on potentially cached associations
    Message.joins(conversation: :conversation_participants)
           .where(conversation_participants: { user_id: id })
           .where.not(sender_id: id)
           .where(read: false)
           .distinct
           .count
  end
  
  private
  
  def create_profile
    case role
    when 'seller'
      create_seller_profile! unless seller_profile
    when 'buyer'
      profile_attrs = {}
      profile_attrs[:buyer_type] = @buyer_type if @buyer_type.present?
      create_buyer_profile!(profile_attrs) unless buyer_profile
    when 'partner'
      profile_attrs = {}
      profile_attrs[:partner_type] = @partner_type if @partner_type.present?
      create_partner_profile!(profile_attrs) unless partner_profile
    end
  end
end
