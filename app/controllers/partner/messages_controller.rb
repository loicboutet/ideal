# frozen_string_literal: true

module Partner
  class MessagesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_partner!
    before_action :set_conversation
    
    def create
      # Ensure user is a participant in the conversation
      unless @conversation.participants.include?(current_user)
        respond_to do |format|
          format.html { redirect_to partner_conversations_path, alert: "Vous n'avez pas accès à cette conversation." }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { alert: "Vous n'avez pas accès à cette conversation." }) }
        end
        return
      end
      
      @message = @conversation.messages.build(message_params)
      @message.sender = current_user
      
      respond_to do |format|
        if @message.save
          # Update participant's last_read_at for sender
          participant = @conversation.conversation_participants.find_by(user_id: current_user.id)
          participant&.update(last_read_at: Time.current)
          
          format.html { redirect_to partner_conversation_path(@conversation), notice: "Message envoyé." }
          format.turbo_stream
        else
          format.html { redirect_to partner_conversation_path(@conversation), alert: "Impossible d'envoyer le message." }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("message_form", partial: "messages/form", locals: { conversation: @conversation, message: @message }) }
        end
      end
    end
    
    private
    
    def ensure_partner!
      unless current_user.partner?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
    
    def set_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end
    
    def message_params
      params.require(:message).permit(:body)
    end
  end
end
