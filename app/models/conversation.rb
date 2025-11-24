class Conversation < ApplicationRecord
  belongs_to :listing, optional: true
  
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, inverse_of: :conversation, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  
  accepts_nested_attributes_for :conversation_participants
  
  validates :conversation_participants, length: { minimum: 2 }, on: :update
  
  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end
  
  def latest_message
    messages.order(created_at: :desc).first
  end
  
  def unread_count_for(user)
    messages.where.not(sender_id: user.id).where(read: false).count
  end
  
  def has_unread_for?(user)
    unread_count_for(user) > 0
  end
  
  def last_message_at
    latest_message&.created_at || created_at
  end
end
