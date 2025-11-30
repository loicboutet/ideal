class Seller::DashboardController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!

  def index
    @seller_profile = current_user.seller_profile
    
    # Get analytics summary
    @analytics_summary = Seller::ListingAnalyticsService.summary_for_seller(@seller_profile)
    
    # Get per-listing analytics for dashboard display
    @listings_with_analytics = Seller::ListingAnalyticsService.listings_with_analytics(@seller_profile)
    
    # Get views growth
    if @seller_profile.listings.any?
      sample_listing = @seller_profile.listings.first
      @views_growth = sample_listing.analytics.views_growth_percentage(days: 30)
    else
      @views_growth = 0
    end
    
    # New interests this week (buyers who favorited seller's listings)
    listing_ids = @seller_profile.listings.pluck(:id)
    @new_interests_this_week = Favorite.where(listing_id: listing_ids)
                                        .where('created_at >= ?', 7.days.ago)
                                        .distinct
                                        .count(:buyer_profile_id)
    
    # Unread messages count
    @unread_messages_count = calculate_unread_messages
  end

  private

  def authorize_seller!
    unless current_user&.seller? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Seller privileges required.'
    end
  end
  
  def calculate_unread_messages
    return 0 unless @seller_profile && current_user
    
    conversations = Conversation.joins(:conversation_participants)
                                 .where(conversation_participants: { user_id: current_user.id })
    
    conversations.sum do |conv|
      participant = conv.conversation_participants.find_by(user_id: current_user.id)
      participant ? conv.messages.where('created_at > ?', participant.last_read_at || Time.at(0)).count : 0
    end
  end
end
