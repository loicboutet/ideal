class Listing < ApplicationRecord
  belongs_to :seller_profile
  belongs_to :attributed_buyer, class_name: 'BuyerProfile', optional: true
  
  has_many :deals, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :enrichments, dependent: :destroy
  has_many :listing_documents, dependent: :destroy
  has_many :listing_views, dependent: :destroy
  has_many :conversations, dependent: :nullify
  
  # Enums
  enum :deal_type, { direct: 0, ideal_mandate: 1, partner_mandate: 2 }
  enum :industry_sector, { 
    industry: 0, construction: 1, commerce: 2, transport_logistics: 3,
    hospitality: 4, services: 5, agrifood: 6, healthcare: 7,
    digital: 8, real_estate: 9, other: 10
  }
  enum :transfer_type, { asset_sale: 0, partial_shares: 1, total_shares: 2, assets: 3 }
  enum :customer_type, { b2b: 0, b2c: 1, mixed: 2 }
  enum :validation_status, { pending: 0, approved: 1, rejected: 2 }
  enum :status, { draft: 0, published: 1, reserved: 2, in_negotiation: 3, sold: 4, withdrawn: 5 }
  
  # Callbacks
  after_update :send_validation_notification, if: :saved_change_to_validation_status?
  
  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :industry_sector, presence: true
  validates :seller_profile_id, presence: true
  
  # Scopes
  scope :approved, -> { where(validation_status: :approved) }
  scope :published_listings, -> { where(status: :published) }
  scope :available, -> { approved.published_listings.where.not(status: [:reserved, :sold]) }
  scope :by_sector, ->(sector) { where(industry_sector: sector) }
  scope :pending_validation, -> { where(validation_status: :pending) }
  scope :approved_listings, -> { where(validation_status: :approved) }
  scope :rejected_listings, -> { where(validation_status: :rejected) }
  
  # Exclusive deal filtering for buyers
  # Returns listings that are either:
  # - Not attributed to anyone (available to all), OR
  # - Attributed to the specific buyer
  scope :available_for_buyer, ->(buyer_profile) {
    where(attributed_buyer_id: nil)
      .or(where(attributed_buyer_id: buyer_profile&.id))
  }
  
  # Returns only listings exclusively attributed to a specific buyer
  scope :attributed_to, ->(buyer_profile) {
    where(attributed_buyer_id: buyer_profile&.id)
  }
  
  # Instance methods
  def increment_views!
    increment!(:views_count)
  end
  
  def pending_validation?
    validation_status == 'pending'
  end
  
  def days_pending
    return nil unless pending_validation? && submitted_at
    ((Time.current - submitted_at.to_time) / 1.day).to_i
  end
  
  def calculate_completeness
    # 60% for listing fields, 40% for documents
    listing_score = calculate_listing_fields_score
    doc_score = calculate_documents_score
    ((listing_score * 0.6) + (doc_score * 0.4)).round
  end
  
  private
  
  def calculate_listing_fields_score
    fields = [
      title, description_public, description_confidential, industry_sector,
      annual_revenue, employee_count, asking_price, transfer_horizon,
      location_department, location_city, net_profit
    ]
    (fields.compact.count.to_f / fields.count * 100).round
  end
  
  def calculate_documents_score
    total_categories = 11
    uploaded = listing_documents.where(not_applicable: false).select(:document_category).distinct.count
    na_count = listing_documents.where(not_applicable: true).select(:document_category).distinct.count
    ((uploaded + na_count).to_f / total_categories * 100).round
  end
  
  def send_validation_notification
    case validation_status
    when 'approved'
      update_column(:validated_at, Time.current) unless validated_at
      ListingNotificationMailer.listing_approved(self).deliver_later
    when 'rejected'
      ListingNotificationMailer.listing_rejected(self).deliver_later
    end
  end
end
