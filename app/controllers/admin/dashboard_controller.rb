class Admin::DashboardController < ApplicationController
  layout 'admin'
  
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # Get date range from params or default to 30 days
    date_range = get_date_range(params[:date_range])
    
    # Key Metrics with evolution
    total_users = User.where('created_at >= ?', date_range[:start]).count
    prev_period_users = User.where('created_at >= ? AND created_at < ?', date_range[:prev_start], date_range[:start]).count
    user_evolution = prev_period_users > 0 ? (((total_users - prev_period_users).to_f / prev_period_users) * 100).round : 0
    
    active_listings = Listing.where(validation_status: :approved, status: :published)
                             .where('created_at >= ?', date_range[:start]).count
    prev_period_listings = Listing.where(validation_status: :approved, status: :published)
                                  .where('created_at >= ? AND created_at < ?', date_range[:prev_start], date_range[:start]).count
    listing_evolution = prev_period_listings > 0 ? (((active_listings - prev_period_listings).to_f / prev_period_listings) * 100).round : 0
    
    pending_validations = Listing.where(validation_status: :pending).count
    
    # Calculate revenue for selected period
    monthly_revenue = calculate_revenue_for_period(date_range[:start], date_range[:end])
    prev_period_revenue = calculate_revenue_for_period(date_range[:prev_start], date_range[:start])
    revenue_evolution = prev_period_revenue > 0 ? (((monthly_revenue - prev_period_revenue).to_f / prev_period_revenue) * 100).round : 0
    
    @metrics = {
      total_users: { count: total_users, evolution: user_evolution },
      active_listings: { count: active_listings, evolution: listing_evolution },
      pending_validations: { count: pending_validations, evolution: nil },
      monthly_revenue: { amount: monthly_revenue, evolution: revenue_evolution }
    }
    
    @user_growth_chart = build_user_growth_chart(date_range)
    @user_distribution = build_user_distribution
    @recent_users = build_recent_users(date_range)
    @recent_listings = build_recent_listings(date_range)
    @recent_activities = build_recent_activities
  end
  
  def operations
    # Alert KPIs
    @zero_views_count = Listing.where(validation_status: :approved, status: :published)
                                .where('views_count = 0 OR views_count IS NULL')
                                .count
    
    @pending_validations_count = Listing.where(validation_status: :pending).count
    
    @pending_reports_count = 0 # Placeholder for reports feature
    
    @expired_timers_count = Deal.where.not(reserved_until: nil)
                                 .where('reserved_until < ?', Time.current)
                                 .count
    
    # CRM stats
    @deals_by_status = Deal.group(:status).count
    
    # Ratio stats
    active_listings = Listing.where(validation_status: :approved, status: :published).count
    paying_buyers = BuyerProfile.where(subscription_status: :active).count
    @listings_per_buyer_ratio = paying_buyers > 0 ? (active_listings.to_f / paying_buyers).round(1) : 0
    @active_listings_count = active_listings
    @paying_buyers_count = paying_buyers
    
    # General KPIs
    @total_users = User.count
    @monthly_revenue = calculate_revenue_for_period(30.days.ago, Time.current)
    @active_reservations = Deal.where(reserved: true).where.not(reserved_until: nil).count
    
    # User distribution
    @user_distribution = build_user_distribution
    
    # Partner usage (top 5)
    @partner_stats = PartnerProfile.joins(:user)
                                    .limit(5)
                                    .map do |partner|
      {
        name: partner.user.company_name || partner.user.full_name,
        type: partner.partner_type&.humanize || 'Partenaire',
        views: rand(100..400), # Placeholder
        contacts: rand(10..40), # Placeholder
        conversion: (rand(50..150) / 10.0).round(1)
      }
    end
  end
  
  def zero_views
    @listings = Listing.where(validation_status: :approved, status: :published)
                       .where('views_count = 0 OR views_count IS NULL')
                       .includes(:seller_profile)
                       .order(created_at: :desc)
                       .page(params[:page]).per(20)
  end
  
  def expired_timers
    @deals = Deal.where.not(reserved_until: nil)
                 .where('reserved_until < ?', Time.current)
                 .includes(:listing, :buyer_profile)
                 .order(reserved_until: :asc)
                 .page(params[:page]).per(20)
  end

  def analytics
    period = params[:period] || '30_days'
    start_date, end_date = parse_period(period)
    
    @analytics = Admin::DashboardAnalyticsService.new(
      period: period, start_date: start_date, end_date: end_date
    )
    
    @crm_time_stats = @analytics.average_time_by_crm_status
    @sector_data = @analytics.listings_by_sector_with_evolution
    @revenue_data = @analytics.listings_by_revenue_range
    @geography_data = @analytics.listings_by_geography
    @employee_data = @analytics.listings_by_employee_count
    
    @listings_series = @analytics.time_series_data(metric: :listings, periods: 8)
    @reservations_series = @analytics.time_series_data(metric: :reservations, periods: 8)
    @transactions_series = @analytics.time_series_data(metric: :transactions, periods: 8)
    @revenue_series = @analytics.time_series_data(metric: :revenue, periods: 8)
    
    @period = period
    @start_date = start_date
    @end_date = end_date

    respond_to do |format|
      format.html
      format.csv { send_analytics_export('csv') }
      format.xlsx { send_analytics_export('xlsx') }
      format.pdf { send_analytics_export('pdf') }
    end
  end

  private

  def authorize_admin!
    unless current_user&.admin? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end
  
  def get_date_range(range_param)
    case range_param
    when '7_days'
      { start: 7.days.ago.beginning_of_day, end: Time.current, prev_start: 14.days.ago.beginning_of_day, duration_days: 7 }
    when 'current_month'
      { start: Time.current.beginning_of_month, end: Time.current, prev_start: 1.month.ago.beginning_of_month, duration_days: Time.current.day }
    when 'previous_month'
      { start: 1.month.ago.beginning_of_month, end: 1.month.ago.end_of_month, prev_start: 2.months.ago.beginning_of_month, duration_days: 1.month.ago.end_of_month.day }
    else
      { start: 30.days.ago.beginning_of_day, end: Time.current, prev_start: 60.days.ago.beginning_of_day, duration_days: 30 }
    end
  end
  
  def calculate_revenue_for_period(start_date, end_date)
    BuyerProfile.where(subscription_status: :active)
                .where('created_at >= ? AND created_at <= ?', start_date, end_date)
                .count * 49
  end
  
  def build_user_growth_chart(date_range)
    periods = []
    period_count = [date_range[:duration_days] / 5, 6].min
    days_per_period = date_range[:duration_days] / period_count
    max_count = 1
    
    period_count.times do |i|
      period_end = date_range[:start] + (i + 1) * days_per_period.days
      period_start = date_range[:start] + i * days_per_period.days
      count = User.where(created_at: period_start..period_end).count
      max_count = [max_count, count].max
      periods << { start: period_start, end: period_end, count: count }
    end
    
    periods.map do |period|
      { month: period[:start].strftime('%d/%m'), count: period[:count], percentage: max_count > 0 ? ((period[:count].to_f / max_count) * 100).round : 20 }
    end
  end
  
  def build_user_distribution
    sellers_count = User.joins(:seller_profile).count
    buyers_count = User.joins(:buyer_profile).count
    partners_count = User.joins(:partner_profile).count
    total = sellers_count + buyers_count + partners_count
    
    [
      { label: 'Cédants', count: sellers_count, percentage: total > 0 ? ((sellers_count.to_f / total) * 100).round : 0, color: 'admin' },
      { label: 'Repreneurs', count: buyers_count, percentage: total > 0 ? ((buyers_count.to_f / total) * 100).round : 0, color: 'green' },
      { label: 'Partenaires', count: partners_count, percentage: total > 0 ? ((partners_count.to_f / total) * 100).round : 0, color: 'admin' }
    ]
  end
  
  def build_recent_users(date_range)
    User.where('created_at >= ?', date_range[:start]).order(created_at: :desc).limit(4).map do |user|
      role = user.seller_profile.present? ? 'seller' : (user.buyer_profile.present? ? 'buyer' : (user.partner_profile.present? ? 'partner' : 'user'))
      role_label = { 'seller' => 'Vendeur', 'buyer' => 'Repreneur', 'partner' => 'Partenaire' }[role] || 'Utilisateur'
      { name: "#{user.first_name} #{user.last_name}".strip.presence || 'Utilisateur', email: user.email, role: role, role_label: role_label, initials: get_initials(user) }
    end
  end
  
  def build_recent_listings(date_range)
    colors = ['admin', 'green', 'purple', 'orange']
    Listing.where('created_at >= ?', date_range[:start]).order(created_at: :desc).limit(4).map.with_index do |listing, index|
      location = listing.location_city && listing.location_department ? "#{listing.location_city} (#{listing.location_department})" : 'Non spécifié'
      { title: listing.title || 'Sans titre', location: location, price: listing.asking_price ? (listing.asking_price / 1000).round : 0,
        status: listing.validation_status, status_label: listing.validation_status == 'approved' ? 'Validée' : 'En attente', color: colors[index % colors.length] }
    end
  end
  
  def build_recent_activities
    activities = []
    
    if (recent_approved = Listing.where(validation_status: :approved).order(updated_at: :desc).first)
      activities << { icon: '<svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" /></svg>',
                      color: 'green', message: "Annonce <span class=\"font-medium text-gray-900\">\"#{recent_approved.title}\"</span> validée", time: time_ago_in_words(recent_approved.updated_at) }
    end
    
    if (recent_user = User.order(created_at: :desc).first)
      role = recent_user.seller_profile.present? ? 'Vendeur' : (recent_user.buyer_profile.present? ? 'Repreneur' : (recent_user.partner_profile.present? ? 'Partenaire' : 'Utilisateur'))
      activities << { icon: '<svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>',
                      color: 'admin', message: "Nouvel utilisateur <span class=\"font-medium text-gray-900\">#{recent_user.first_name} #{recent_user.last_name}</span> inscrit (#{role})", time: time_ago_in_words(recent_user.created_at) }
    end
    
    if (recent_pending = Listing.where(validation_status: :pending).order(created_at: :desc).first)
      activities << { icon: '<svg class="h-5 w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>',
                      color: 'orange', message: "Annonce <span class=\"font-medium text-gray-900\">\"#{recent_pending.title}\"</span> en attente de validation", time: time_ago_in_words(recent_pending.created_at) }
    end
    
    activities
  end
  
  def get_initials(user)
    if user.first_name.present? && user.last_name.present?
      "#{user.first_name[0]}#{user.last_name[0]}".upcase
    elsif user.first_name.present?
      user.first_name[0..1].upcase
    elsif user.email.present?
      user.email[0..1].upcase
    else
      'U'
    end
  end
  
  def time_ago_in_words(time)
    seconds = (Time.current - time).to_i
    if seconds < 60 then "Il y a #{seconds}s"
    elsif seconds < 3600 then "Il y a #{(seconds / 60).round}min"
    elsif seconds < 86400 then "Il y a #{(seconds / 3600).round}h"
    else "Il y a #{(seconds / 86400).round}j"
    end
  end

  def parse_period(period)
    case period
    when '7_days' then [7.days.ago.beginning_of_day, Time.current]
    when '30_days' then [30.days.ago.beginning_of_day, Time.current]
    when 'current_month' then [Time.current.beginning_of_month, Time.current]
    when 'previous_month' then [1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
    when '3_months' then [3.months.ago.beginning_of_day, Time.current]
    when '6_months' then [6.months.ago.beginning_of_day, Time.current]
    when '1_year' then [1.year.ago.beginning_of_day, Time.current]
    else [30.days.ago.beginning_of_day, Time.current]
    end
  end

  def send_analytics_export(format_type)
    export_service = Admin::AnalyticsExportService.new(period: @period, start_date: @start_date, end_date: @end_date, scope: params[:scope] || 'current')
    case format_type
    when 'csv' then send_data export_service.to_csv, filename: "analytics_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.csv", type: 'text/csv'
    when 'xlsx' then send_data export_service.to_excel, filename: "analytics_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.xlsx", type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    when 'pdf' then send_data export_service.to_pdf, filename: "analytics_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.pdf", type: 'application/pdf'
    end
  end
end
