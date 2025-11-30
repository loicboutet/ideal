class Buyer::DashboardController < ApplicationController
  layout 'buyer'
  
  before_action :authenticate_user!
  before_action :authorize_buyer!

  def index
    @buyer_profile = current_user.buyer_profile
    
    # Fetch all deals for the buyer
    @deals = Deal.where(buyer_profile: @buyer_profile).includes(:listing).order(updated_at: :desc)
    
    # Deal counts by stage
    @deals_by_stage = @deals.group(:status).count
    
    # Active reservations (deals with active timers)
    @active_reservations = @deals.where(reserved: true).where.not(reserved_until: nil).order(:reserved_until)
    
    # Expiring soon (within 24 hours)
    @expiring_soon = @active_reservations.where('reserved_until <= ?', 24.hours.from_now)
    
    # Calculate shortest timer remaining
    if @active_reservations.any?
      shortest = @active_reservations.first
      @shortest_timer_days = [(shortest.reserved_until - Time.current).to_i / 1.day, 0].max if shortest.reserved_until
    end
    
    # Recent favorites (last 5)
    @recent_favorites = Favorite.where(buyer_profile: @buyer_profile)
                                .includes(listing: :seller_profile)
                                .order(created_at: :desc)
                                .limit(5)
    
    # New favorites in last 7 days
    @new_favorites_count = Favorite.where(buyer_profile: @buyer_profile)
                                    .where('created_at >= ?', 7.days.ago)
                                    .count
    
    # Unread messages count - use user_id instead of participant
    unread_count = 0
    if @buyer_profile && current_user
      conversations = Conversation.joins(:conversation_participants)
                                   .where(conversation_participants: { user_id: current_user.id })
      unread_count = conversations.sum do |conv|
        participant = conv.conversation_participants.find_by(user_id: current_user.id)
        participant ? conv.messages.where('created_at > ?', participant.last_read_at || Time.at(0)).count : 0
      end
    end
    
    # Quick stats
    @stats = {
      total_deals: @deals.count,
      active_reservations: @active_reservations.count,
      favorites: Favorite.where(buyer_profile: @buyer_profile).count,
      credits: @buyer_profile&.credits || 0,
      unread_messages: unread_count
    }
    
    # Available listings count
    @available_listings_count = Listing.where(status: :active).count
    
    # Recent activity (last 5 deal updates)
    @recent_activity = @deals.limit(5)
    
    # Subscription info
    @subscription_name = @buyer_profile&.subscription_plan&.titleize || 'Freemium'
    @subscription_end_date = @buyer_profile&.subscription_expires_at&.strftime('%d/%m/%Y')
    @max_reservations = @buyer_profile&.subscription_plan == 'premium' ? 'illimité' : 3
    
    # CRM stage names and counts for pipeline overview
    @stages = build_pipeline_stages
  end

  private

  def authorize_buyer!
    unless current_user&.buyer? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Buyer privileges required.'
    end
  end
  
  def build_pipeline_stages
    stage_config = [
      { name: 'favoris', label: 'Favoris', short_label: 'Fav', color: 'gray' },
      { name: 'a_contacter', label: 'À contacter', short_label: 'Contact', color: 'blue' },
      { name: 'echange_infos', label: "Échange d'infos", short_label: 'Échange', color: 'blue' },
      { name: 'analyse', label: 'Analyse', short_label: 'Analyse', color: 'blue' },
      { name: 'alignement_projets', label: 'Alignement projets', short_label: 'Align.', color: 'blue' },
      { name: 'negociation', label: 'Négociation', short_label: 'Négo', color: 'green' },
      { name: 'loi', label: 'LOI', short_label: 'LOI', color: 'green' },
      { name: 'audits', label: 'Audits', short_label: 'Audits', color: 'green' },
      { name: 'financement', label: 'Financement', short_label: 'Finance', color: 'green' },
      { name: 'signe', label: 'Deal signé', short_label: 'Signé', color: 'purple' }
    ]
    
    stage_config.map do |stage|
      stage.merge(count: @deals_by_stage[stage[:name]] || 0)
    end
  end
end
