class Admin::DashboardController < ApplicationController
  layout 'admin'
  
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # Initialize analytics service with period filter
    @period = params[:period] || 'month'
    @analytics = Admin::DashboardAnalyticsService.new(
      period: @period,
      start_date: params[:start_date],
      end_date: params[:end_date]
    )
    
    # Alert KPIs (clickable)
    @alerts = {
      zero_view_listings: @analytics.zero_view_listings_count,
      pending_validations: @analytics.pending_validations_count,
      pending_reports: @analytics.pending_reports_count,
      expired_timers: @analytics.expired_timers_count
    }
    
    # Key Ratios
    @listings_per_buyer_ratio = @analytics.listings_per_buyer_ratio
    
    # Satisfaction
    @satisfaction = {
      current: @analytics.satisfaction_percentage,
      evolution: @analytics.satisfaction_evolution
    }
    
    # Growth Metrics (with evolution)
    @growth_metrics = @analytics.growth_metrics
    
    # Charts Data
    @deals_by_status = @analytics.deals_by_status
    @abandoned_deals = @analytics.abandoned_deals_breakdown
    
    # User Distribution
    @user_distribution = @analytics.user_distribution_with_evolution
    
    # Spending by Category
    @spending_by_category = @analytics.spending_by_category
    
    # Partner Usage
    @partner_usage = @analytics.partner_usage_stats
    @partner_usage_trend = @analytics.partner_usage_trend(months: 6)
    
    # Basic stats (kept for backward compatibility)
    @pending_listings = Listing.where(validation_status: :pending).count
    @pending_partners = PartnerProfile.where(validation_status: :pending).count
  end
  
  def zero_views
    @listings = Listing.where(validation_status: :approved)
                       .where(status: :published)
                       .where('views_count = 0 OR views_count IS NULL')
                       .includes(:seller_profile)
                       .order(created_at: :desc)
                       .page(params[:page]).per(20)
  end
  
  def expired_timers
    @deals = Deal.active
                 .where.not(reserved_until: nil)
                 .where('reserved_until < ?', Time.current)
                 .includes(:listing, :buyer_profile)
                 .order(reserved_until: :asc)
                 .page(params[:page]).per(20)
  end

  private

  def authorize_admin!
    unless current_user&.admin? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end
end
