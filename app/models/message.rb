class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  
  validates :conversation_id, presence: true
  validates :sender_id, presence: true
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }
  
  after_create :send_notification
  after_create :broadcast_message
  
  scope :unread, -> { where(read: false) }
  
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
  
  private
  
  def send_notification
    # Send email notification to recipient
  end
  
  def broadcast_message
    # Broadcast via Turbo Streams for real-time updates
  end
end
