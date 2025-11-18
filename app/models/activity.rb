class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true
  
  enum action_type: {
    user_created: 0, user_updated: 1, listing_created: 2, listing_validated: 3,
    listing_rejected: 4, deal_created: 5, deal_updated: 6, deal_released: 7,
    nda_signed: 8, payment_processed: 9, import_completed: 10, message_sent: 11,
    document_uploaded: 12, enrichment_submitted: 13, settings_updated: 14
  }
  
  validates :action_type, presence: true
  
  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :by_user, ->(user) { where(user: user) }
end
