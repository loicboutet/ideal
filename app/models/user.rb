class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Enums
  enum role: { admin: 0, seller: 1, buyer: 2, partner: 3 }
  enum status: { pending: 0, active: 1, suspended: 2 }

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
  
  # Validations
  validates :role, presence: true
  validates :status, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  # Callbacks
  after_create :create_profile
  
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
  
  private
  
  def create_profile
    case role
    when 'seller'
      create_seller_profile! unless seller_profile
    when 'buyer'
      create_buyer_profile! unless buyer_profile
    when 'partner'
      create_partner_profile! unless partner_profile
    end
  end
end
