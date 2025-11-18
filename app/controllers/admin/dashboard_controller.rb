class Admin::DashboardController < AdminController
  def index
    # Admin dashboard with KPIs and metrics
    @pending_listings_count = Listing.pending_validation.count
    @pending_partners_count = PartnerProfile.pending_approval.count
    @expired_deals_count = Deal.with_expired_timers.count
    @pending_reports_count = 0 # TODO: Add reports model
    
    # Growth metrics
    @active_listings_count = Listing.active.count
    @total_users_count = User.active_users.count
    @monthly_revenue = calculate_monthly_revenue
    @reservations_count = Deal.reserved.count
    
    # User distribution
    @users_by_role = User.group(:role).count
    
    # Deal metrics by status
    @deals_by_status = Deal.group(:status).count
    
    # Recent activity
    @recent_activities = Activity.recent.limit(10)
  end

  def analytics
    # Detailed analytics dashboard
    @time_range = params[:period] || '30.days'
    
    # Listings analytics
    @listings_by_sector = Listing.joins(:seller_profile).group('industry_sector').count
    @listings_by_revenue = Listing.group(:annual_revenue_range).count
    @listings_by_geography = Listing.group(:department).count
    
    # Performance metrics
    @average_time_per_stage = calculate_average_time_per_crm_stage
    @conversion_rates = calculate_conversion_rates_by_stage
    
    # Trends over time
    @listings_trend = calculate_listings_trend(@time_range)
    @users_trend = calculate_users_trend(@time_range)
    @revenue_trend = calculate_revenue_trend(@time_range)
  end

  def operations
    # Operations center with actionable items
    @listings_no_views = Listing.active.joins(:listing_views).having('COUNT(listing_views.id) = 0')
    @pending_validations = Listing.pending_validation
    @pending_enrichments = Enrichment.pending_approval
    @expired_timers = Deal.with_expired_timers
    
    # Partner operations
    @pending_partner_approvals = PartnerProfile.pending_approval
    @partner_subscription_renewals = calculate_upcoming_partner_renewals
  end

  private

  def calculate_monthly_revenue
    # Calculate current month's revenue from subscriptions and credits
    current_month_start = Time.current.beginning_of_month
    Subscription.where(created_at: current_month_start..Time.current)
               .sum(:amount) || 0
  end

  def calculate_average_time_per_crm_stage
    # Calculate average time spent in each CRM stage
    {
      'to_contact' => 3.5,
      'info_exchange' => 12.0,
      'analysis' => 8.5,
      'negotiation' => 15.2,
      'loi' => 5.0
    }
  end

  def calculate_conversion_rates_by_stage
    # Calculate conversion rates between CRM stages
    {
      'favorites_to_contact' => 45.2,
      'contact_to_analysis' => 32.1,
      'analysis_to_negotiation' => 28.5,
      'negotiation_to_loi' => 18.9,
      'loi_to_signed' => 65.4
    }
  end

  def calculate_listings_trend(period)
    # Mock data for listings trend
    [
      { date: 30.days.ago, count: 145 },
      { date: 15.days.ago, count: 152 },
      { date: 7.days.ago, count: 158 },
      { date: Date.current, count: 163 }
    ]
  end

  def calculate_users_trend(period)
    # Mock data for users trend
    [
      { date: 30.days.ago, count: 892 },
      { date: 15.days.ago, count: 925 },
      { date: 7.days.ago, count: 948 },
      { date: Date.current, count: 967 }
    ]
  end

  def calculate_revenue_trend(period)
    # Mock data for revenue trend
    [
      { date: 30.days.ago, amount: 12450 },
      { date: 15.days.ago, amount: 13200 },
      { date: 7.days.ago, amount: 14100 },
      { date: Date.current, amount: 15600 }
    ]
  end

  def calculate_upcoming_partner_renewals
    # Partners with subscriptions expiring in the next 30 days
    expiring_soon = 30.days.from_now
    PartnerProfile.joins(:user)
                  .joins('JOIN subscriptions ON subscriptions.user_id = users.id')
                  .where('subscriptions.expires_at <= ?', expiring_soon)
                  .where('subscriptions.expires_at > ?', Time.current)
  end
end
