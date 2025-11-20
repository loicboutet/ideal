class Enrichment < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  belongs_to :validated_by, class_name: 'User', optional: true
  
  # Active Storage attachment for file upload
  has_one_attached :document
  
  enum :document_category, {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  enum :validation_status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }
  
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :document_category, presence: true
  
  scope :validated_enrichments, -> { where(validated: true) }
  scope :pending_validation, -> { where(validation_status: :pending) }
  scope :approved_enrichments, -> { where(validation_status: :approved) }
  scope :rejected_enrichments, -> { where(validation_status: :rejected) }
  
  # Callbacks
  after_update :award_credits_on_approval, if: :saved_change_to_validation_status?
  after_update :sync_validated_flag, if: :saved_change_to_validation_status?
  
  # Instance methods
  def category_label
    I18n.t("enrichments.categories.#{document_category}", default: document_category.humanize)
  end
  
  private
  
  def award_credits_on_approval
    return unless approved? && listing.seller_profile.present?
    
    # Award +1 credit to seller for validated enrichment
    listing.seller_profile.award_credits(
      1,
      :enrichment_validated,
      source: self,
      description: "Document enrichi validé : #{category_label}"
    )
    
    # Update credits_awarded field
    update_column(:credits_awarded, 1)
    
    # Update validated flag for backward compatibility
    update_column(:validated, true) unless validated?
    
    # Notify buyer that document was approved
    create_approval_notification
  end
  
  def sync_validated_flag
    # Keep the old validated boolean in sync
    update_column(:validated, approved?)
  end
  
  def create_approval_notification
    Notification.create(
      user: buyer_profile.user,
      notification_type: :enrichment_approved,
      title: "Document validé",
      message: "Votre enrichissement (#{category_label}) pour l'annonce \"#{listing.title}\" a été validé par le cédant.",
      link_url: Rails.application.routes.url_helpers.buyer_listing_path(listing)
    )
  rescue => e
    Rails.logger.error "Failed to create enrichment approval notification: #{e.message}"
  end
end
