# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]
  
  def index
    # Get all conversations where current user is a participant
    @conversations = current_user.conversations
                                 .includes(:listing, :participants, :messages)
                                 .order('messages.created_at DESC')
                                 .distinct
  end
  
  def show
    # Ensure user is a participant
    unless @conversation.participants.include?(current_user)
      redirect_to conversations_path, alert: "Vous n'avez pas accès à cette conversation."
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
  
  def create
    # Find or create conversation between users about a listing
    listing = Listing.find(params[:listing_id])
    other_user = User.find(params[:recipient_id])
    
    # Check if conversation already exists
    @conversation = find_or_create_conversation(listing, other_user)
    
    if @conversation.persisted?
      redirect_to @conversation, notice: "Conversation démarrée."
    else
      redirect_back fallback_location: root_path, alert: "Impossible de créer la conversation."
    end
  end
  
  private
  
  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
  
  def find_or_create_conversation(listing, other_user)
    # Find existing conversation between these users about this listing
    conversation = Conversation.joins(:conversation_participants)
                               .where(listing_id: listing.id)
                               .group('conversations.id')
                               .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                               .where(conversation_participants: { user_id: [current_user.id, other_user.id] })
                               .first
    
    return conversation if conversation.present?
    
    # Create new conversation
    Conversation.create(listing: listing, subject: "Re: #{listing.title}") do |conv|
      conv.conversation_participants.build(user: current_user)
      conv.conversation_participants.build(user: other_user)
    end
  end
end
