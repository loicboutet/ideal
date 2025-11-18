class PartnerProfile < ApplicationRecord
  belongs_to :user
  
  has_many :partner_contacts, dependent: :destroy
  
  # Enums
  enum partner_type: { lawyer: 0, accountant: 1, consultant: 2, banker: 3, broker: 4, other: 5 }
  enum validation_status: { pending: 0, approved: 1, rejected: 2 }
  enum coverage_area: { city: 0, department: 1, region: 2, nationwide: 3, international: 4 }
  
  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :partner_type, presence: true
  validates :website, format: { with: URI::regexp(%w[http https]), allow_blank: true }
  validates :calendar_link, format: { with: URI::regexp(%w[http https]), allow_blank: true }
  
  # Serialization for JSON fields
  serialize :intervention_stages, type: Array, coder: JSON
  serialize :industry_specializations, type: Array, coder: JSON
  
  # Scopes
  scope :approved, -> { where(validation_status: :approved) }
  scope :active_subscription, -> { where('directory_subscription_expires_at > ?', Time.current) }
  scope :by_type, ->(type) { where(partner_type: type) }
  scope :by_coverage, ->(area) { where(coverage_area: area) }
  
  # Instance methods
  def subscription_active?
    directory_subscription_expires_at.present? && directory_subscription_expires_at > Time.current
  end
  
  def increment_views!
    increment!(:views_count)
  end
  
  def increment_contacts!
    increment!(:contacts_count)
  end
end
