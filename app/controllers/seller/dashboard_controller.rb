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
  end

  private

  def authorize_seller!
    unless current_user&.seller? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Seller privileges required.'
    end
  end
end
