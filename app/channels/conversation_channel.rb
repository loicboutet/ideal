# frozen_string_literal: true

class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is a participant in the conversation
    if conversation.participants.include?(current_user)
      stream_from "conversation_#{conversation.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def speak(data)
    conversation = Conversation.find(params[:conversation_id])
    
    # Verify user is a participant
    return unless conversation.participants.include?(current_user)
    
    message = conversation.messages.build(
      sender: current_user,
      body: data['message']
    )
    
    if message.save
      # Update participant's last_read_at for sender
      participant = conversation.conversation_participants.find_by(user_id: current_user.id)
      participant&.update(last_read_at: Time.current)
    end
  end
end
