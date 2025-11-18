class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  
  validates :conversation_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :conversation_id }
end
