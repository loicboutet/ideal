class DealHistoryEvent < ApplicationRecord
  belongs_to :deal
  belongs_to :user, optional: true
  
  enum event_type: {
    status_change: 0, document_added: 1, message_sent: 2,
    reservation: 3, release: 4, timer_extended: 5, loi_validated: 6
  }
  
  validates :deal_id, presence: true
  validates :event_type, presence: true
end
