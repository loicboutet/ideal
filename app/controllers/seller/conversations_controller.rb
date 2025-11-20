# frozen_string_literal: true

module Seller
  class ConversationsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!
    before_action :set_conversation, only: [:show]
    
  def index
    @conversations = current_user.conversations
                                 .includes(:listing, :participants, :messages)
                                 .order('messages.created_at DESC')
                                 .distinct
    
    # Handle conversation selection for split-pane view
    if params[:conversation_id].present?
      @selected_conversation = @conversations.find_by(id: params[:conversation_id])
      
      if @selected_conversation
        # Mark messages as read
        @selected_conversation.messages
                              .where.not(sender_id: current_user.id)
                              .where(read: false)
                              .update_all(read: true, read_at: Time.current)
        
        # Update participant's last_read_at
        participant = @selected_conversation.conversation_participants.find_by(user_id: current_user.id)
        participant&.update(last_read_at: Time.current)
        
        @messages = @selected_conversation.messages.includes(:sender).order(created_at: :asc)
        @message = Message.new
      end
    end
    
    # Handle search
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @conversations = @conversations.joins(:participants)
                                    .where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR listings.title ILIKE ?", 
                                           search_term, search_term, search_term)
                                    .distinct
    end
  end
    
    def new
      # For selecting a buyer to message
      @buyers = User.buyers.active_users
      @my_listings = current_user.seller_profile&.listings&.where(status: 'active') || []
    end
    
    def create
      # TODO: TEMPORARILY DISABLED FOR TESTING - sellers can message any buyer
      buyer = User.buyers.find(params[:buyer_id])
      listing = params[:listing_id].present? ? Listing.find(params[:listing_id]) : nil
      
      # Find or create conversation
      @conversation = find_or_create_conversation(listing, buyer)
      
      if @conversation.persisted?
        redirect_to seller_conversations_path(conversation_id: @conversation.id), notice: "Conversation démarrée."
      else
        redirect_back fallback_location: seller_conversations_path, 
                      alert: "Impossible de créer la conversation."
      end
    end
    
    def show
      # Redirect to index with conversation selected to maintain consistent UI
      redirect_to seller_conversations_path(conversation_id: params[:id])
    end
    
    def create_partner_conversation
      # Sellers can contact partners from directory
      partner = User.partners.find(params[:partner_id])
      
      # Find or create conversation (no listing context)
      @conversation = find_or_create_conversation(nil, partner)
      
      if @conversation.persisted?
        redirect_to seller_conversations_path(conversation_id: @conversation.id), notice: "Conversation avec le partenaire démarrée."
      else
        redirect_back fallback_location: seller_partners_path, 
                      alert: "Impossible de créer la conversation."
      end
    end
    
    private
    
    def ensure_seller!
      unless current_user.seller?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
    
    def set_conversation
      @conversation = Conversation.find(params[:id])
    end
    
    def find_or_create_conversation(listing, other_user)
      # Find existing conversation between these users
      if listing
        conversation = Conversation.joins(:conversation_participants)
                                   .where(listing_id: listing.id)
                                   .group('conversations.id')
                                   .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                                   .where(conversation_participants: { user_id: [current_user.id, other_user.id] })
                                   .first
      else
        # For partner conversations (no listing)
        conversation = Conversation.joins(:conversation_participants)
                                   .where(listing_id: nil)
                                   .group('conversations.id')
                                   .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                                   .where(conversation_participants: { user_id: [current_user.id, other_user.id] })
                                   .first
      end
      
      return conversation if conversation.present?
      
      # Create new conversation with transaction
      subject = listing ? "Re: #{listing.title}" : "Conversation avec #{other_user.full_name}"
      
      Conversation.transaction do
        conversation = Conversation.new(listing: listing, subject: subject)
        conversation.conversation_participants.build(user: current_user)
        conversation.conversation_participants.build(user: other_user)
        conversation.save!
        conversation
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create conversation: #{e.message}"
      Conversation.new # Return unsaved conversation to trigger error handling
    end
  end
end
