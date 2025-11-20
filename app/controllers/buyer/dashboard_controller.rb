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
    
    # Recent favorites (last 5)
    @recent_favorites = Favorite.where(buyer_profile: @buyer_profile)
                                .includes(listing: :seller_profile)
                                .order(created_at: :desc)
                                .limit(5)
    
    # Quick stats
    @stats = {
      total_deals: @deals.count,
      active_reservations: @active_reservations.count,
      favorites: Favorite.where(buyer_profile: @buyer_profile).count,
      credits: @buyer_profile&.credits || 0
    }
    
    # Recent activity (last 5 deal updates)
    @recent_activity = @deals.limit(5)
    
    # CRM stage names and counts for pipeline overview
    @stages = Deal.statuses.keys.reject { |s| ['released', 'abandoned'].include?(s) }.map do |stage|
      {
        name: stage,
        label: I18n.t("deal.statuses.#{stage}", default: stage.humanize),
        count: @deals_by_stage[stage] || 0
      }
    end
  end

  private

  def authorize_buyer!
    unless current_user&.buyer? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Buyer privileges required.'
    end
  end
end
