class Conversation < ApplicationRecord
  belongs_to :listing, optional: true
  
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  
  validates :conversation_participants, length: { minimum: 2 }
  
  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end
  
  def latest_message
    messages.order(created_at: :desc).first
  end
end
