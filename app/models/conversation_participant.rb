class ConversationParticipant < ApplicationRecord
  belongs_to :conversation, inverse_of: :conversation_participants
  belongs_to :user
  
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :conversation_id }, if: :persisted?
end
