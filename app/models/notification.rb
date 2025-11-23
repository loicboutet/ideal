class Notification < ApplicationRecord
  belongs_to :user
  
  enum :notification_type, {
    new_deal: 0, listing_validated: 1, listing_rejected: 2,
    favorite_available: 3, reservation_expiring: 4, subscription_expiring: 5,
    enrichment_validated: 6, new_message: 7, deal_status_changed: 8,
    document_validation_request: 9, listing_pushed: 10, buyer_interested: 11,
    timer_expired: 12, loi_validation_request: 13, credit_earned: 14,
    exclusive_deal_assigned: 15, deal_reserved: 16, deal_released: 17
  }
  
  validates :user_id, presence: true
  validates :notification_type, presence: true
  validates :title, presence: true
  validates :message, presence: true
  
  scope :unread, -> { where(read: false) }
  
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
end
