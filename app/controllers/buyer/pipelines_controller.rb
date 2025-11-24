class Buyer::PipelinesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role

  def show
    @buyer_profile = current_user.buyer_profile
    
    # Get all active deals for this buyer, grouped by status
    active_deals = @buyer_profile.deals.active.includes(:listing).order(stage_entered_at: :desc)
    
    # Group deals by status
    @deals_by_status = Deal.statuses.keys.each_with_object({}) do |status, hash|
      hash[status] = active_deals.select { |deal| deal.status == status }
    end
    
    # Get released deals separately
    @released_deals = @buyer_profile.deals.where.not(released_at: nil).includes(:listing).order(released_at: :desc).limit(10)
    
    # Calculate statistics
    @total_active_deals = active_deals.count
    @deals_with_active_timer = active_deals.select { |d| d.reserved_until.present? && !d.timer_expired? }.count
    @time_extending_deals = active_deals.select { |d| d.time_extending? }.count
  end

  private

  def ensure_buyer_role
    unless current_user.buyer?
      redirect_to root_path, alert: "Accès non autorisé"
    end
  end
end
