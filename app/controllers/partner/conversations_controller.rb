# frozen_string_literal: true

module Partner
  class ConversationsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_partner!
    before_action :set_conversation, only: [:show]
    
    def index
      @conversations = current_user.conversations
                                   .includes(:listing, :participants, :messages)
                                   .order('messages.created_at DESC')
                                   .distinct
    end
    
    def show
      # Ensure user is a participant
      unless @conversation.participants.include?(current_user)
        redirect_to partner_conversations_path, alert: "Vous n'avez pas accès à cette conversation."
        return
      end
      
      # Mark messages as read
      @conversation.messages
                   .where.not(sender_id: current_user.id)
                   .where(read: false)
                   .update_all(read: true, read_at: Time.current)
      
      # Update participant's last_read_at
      participant = @conversation.conversation_participants.find_by(user_id: current_user.id)
      participant&.update(last_read_at: Time.current)
      
      @messages = @conversation.messages.includes(:sender).order(created_at: :asc)
      @message = Message.new
    end
    
    private
    
    def ensure_partner!
      unless current_user.partner?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
    
    def set_conversation
      @conversation = Conversation.find(params[:id])
    end
  end
end
