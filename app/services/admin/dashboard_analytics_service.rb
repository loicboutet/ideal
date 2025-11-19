# frozen_string_literal: true

module Admin
  class DashboardAnalyticsService
    attr_reader :period, :start_date, :end_date

    def initialize(period: 'month', start_date: nil, end_date: nil)
      @period = period
      @end_date = end_date&.to_date || Date.current
      @start_date = start_date&.to_date || calculate_start_date
    end

    # Alert KPIs
    def zero_view_listings_count
      Listing.where(validation_status: :approved)
             .where(status: :published)
             .where('views_count = 0 OR views_count IS NULL')
             .count
    end

    def pending_validations_count
      Listing.where(validation_status: :pending).count +
        PartnerProfile.where(validation_status: :pending).count
    end

    def pending_reports_count
      # Placeholder - will be 0 until Report model is created
      0
    end

    def expired_timers_count
      Deal.active
          .where.not(reserved_until: nil)
          .where('reserved_until < ?', Time.current)
          .count
    end

    # Deals by Status (for bar chart)
    def deals_by_status
      Deal.where(created_at: @start_date..@end_date)
          .group(:status)
          .count
          .transform_keys { |k| k.to_s.humanize }
    end

    # Abandoned Deals Analysis
    def abandoned_deals_breakdown
      abandoned = Deal.where(status: :abandoned)
                      .where(created_at: @start_date..@end_date)
      
      {
        voluntary: abandoned.where('released_at IS NOT NULL').count,
        timer_expired: abandoned.where('reserved_until < released_at').count
      }
    end

    # Key Ratios
    def listings_per_buyer_ratio
      available = Listing.where(validation_status: :approved, status: :published).count
      paying = BuyerProfile.where(subscription_status: :active)
                          .where('subscription_expires_at IS NULL OR subscription_expires_at > ?', Time.current)
                          .count
      
      return 0 if paying.zero?
      (available.to_f / paying).round(2)
    end

    # Satisfaction (placeholder - requires survey implementation)
    def satisfaction_percentage
      # TODO: Calculate from satisfaction surveys when implemented
      0
    end

    def satisfaction_evolution
      # TODO: Compare with previous period
      0
    end

    # Growth Metrics
    def growth_metrics
      {
        active_listings: growth_metric_for_listings,
        monthly_revenue: growth_metric_for_revenue,
        total_users: growth_metric_for_users,
        reservations: growth_metric_for_reservations
      }
    end

    # User Distribution
    def user_distribution
      User.where(created_at: @start_date..@end_date)
          .group(:role)
          .count
    end

    def user_distribution_with_evolution
      current = User.group(:role).count
      previous = User.where('created_at < ?', @start_date).group(:role).count
      
      current.transform_values do |count|
        prev_count = previous[count] || 0
        evolution = prev_count.zero? ? 100 : ((count - prev_count).to_f / prev_count * 100).round(1)
        { current: count, evolution: evolution }
      end
    end

    # Spending by Category (placeholder - requires payment tracking)
    def spending_by_category
      {
        buyers: 0,  # TODO: Calculate from subscriptions/credit purchases
        sellers: 0, # TODO: Calculate from credit purchases
        partners: 0 # TODO: Calculate from directory subscriptions
      }
    end

    # Partner Usage Analytics
    def partner_usage_stats
      {
        total_views: PartnerProfile.sum(:views_count),
        total_contacts: PartnerContact.count,
        active_partners: PartnerProfile.where(validation_status: :approved).count
      }
    end

    def partner_usage_trend(months: 6)
      # Monthly trend for the last N months
      result = []
      months.times do |i|
        month_start = (Date.current - i.months).beginning_of_month
        month_end = month_start.end_of_month
        
        result << {
          month: month_start.strftime('%b %Y'),
          views: PartnerProfile.where('updated_at BETWEEN ? AND ?', month_start, month_end)
                               .sum(:views_count),
          contacts: PartnerContact.where(created_at: month_start..month_end).count
        }
      end
      
      result.reverse
    end

    private

    def calculate_start_date
      case @period
      when 'day'
        @end_date.beginning_of_day
      when 'week'
        @end_date.beginning_of_week
      when 'month'
        @end_date.beginning_of_month
      when 'quarter'
        @end_date.beginning_of_quarter
      when 'year'
        @end_date.beginning_of_year
      else
        @end_date.beginning_of_month
      end
    end

    def previous_period_dates
      duration = @end_date - @start_date
      prev_end = @start_date - 1.day
      prev_start = prev_end - duration
      [prev_start, prev_end]
    end

    def growth_metric_for_listings
      current = Listing.where(validation_status: :approved, status: :published).count
      prev_start, prev_end = previous_period_dates
      previous = Listing.where(validation_status: :approved, status: :published)
                        .where('created_at <= ?', prev_end)
                        .count
      
      calculate_growth(current, previous)
    end

    def growth_metric_for_revenue
      # Placeholder - calculate MRR when subscription payments are implemented
      { current: 0, evolution: 0 }
    end

    def growth_metric_for_users
      current = User.count
      prev_start, prev_end = previous_period_dates
      previous = User.where('created_at <= ?', prev_end).count
      
      calculate_growth(current, previous)
    end

    def growth_metric_for_reservations
      current = Deal.where(reserved: true).count
      prev_start, prev_end = previous_period_dates
      previous = Deal.where(reserved: true)
                     .where('reserved_at <= ?', prev_end)
                     .count
      
      calculate_growth(current, previous)
    end

    def calculate_growth(current, previous)
      evolution = if previous.zero?
                    current.zero? ? 0 : 100
                  else
                    ((current - previous).to_f / previous * 100).round(1)
                  end
      
      { current: current, evolution: evolution }
    end
  end
end
