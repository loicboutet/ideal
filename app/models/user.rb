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
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
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
  attr_accessor :buyer_type, :company_name, :partner_type
  
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
    conversations.sum { |c| c.unread_count_for(self) }
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
