class MessageRecipient < ApplicationRecord
  belongs_to :admin_message
  belongs_to :user
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
end
