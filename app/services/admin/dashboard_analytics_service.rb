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

    # Satisfaction tracking from surveys
    def satisfaction_percentage
      # Calculate average satisfaction score from all satisfaction surveys
      avg_score = SurveyResponse.joins(:survey)
                                .where(surveys: { survey_type: 'satisfaction', active: true })
                                .where.not(satisfaction_score: nil)
                                .average(:satisfaction_score)
      
      return 0 if avg_score.nil?
      
      # Convert 1-5 scale to percentage (5 stars = 100%)
      ((avg_score / 5.0) * 100).round(1)
    end

    def satisfaction_evolution
      # Compare current period with previous period
      current_avg = SurveyResponse.joins(:survey)
                                  .where(surveys: { survey_type: 'satisfaction', active: true })
                                  .where(survey_responses: { created_at: @start_date..@end_date })
                                  .where.not(satisfaction_score: nil)
                                  .average(:satisfaction_score)
      
      prev_start, prev_end = previous_period_dates
      previous_avg = SurveyResponse.joins(:survey)
                                   .where(surveys: { survey_type: 'satisfaction', active: true })
                                   .where(survey_responses: { created_at: prev_start..prev_end })
                                   .where.not(satisfaction_score: nil)
                                   .average(:satisfaction_score)
      
      return 0 if current_avg.nil? || previous_avg.nil? || previous_avg.zero?
      
      ((current_avg - previous_avg) / previous_avg * 100).round(1)
    end
    
    # Detailed satisfaction metrics
    def satisfaction_metrics
      responses = SurveyResponse.joins(:survey)
                                .where(surveys: { survey_type: 'satisfaction', active: true })
                                .where.not(satisfaction_score: nil)
      
      total_responses = responses.count
      return default_satisfaction_metrics if total_responses.zero?
      
      {
        average_score: responses.average(:satisfaction_score)&.round(2) || 0,
        total_responses: total_responses,
        distribution: responses.group(:satisfaction_score).count,
        response_rate: calculate_satisfaction_response_rate,
        recent_comments: recent_satisfaction_comments(5)
      }
    end
    
  
    
    def default_satisfaction_metrics
      {
        average_score: 0,
        total_responses: 0,
        distribution: {},
        response_rate: 0,
        recent_comments: []
      }
    end
    
    def calculate_satisfaction_response_rate
      satisfaction_surveys = Survey.where(survey_type: 'satisfaction', active: true)
      return 0 if satisfaction_surveys.empty?
      
      total_recipients = satisfaction_surveys.sum do |survey|
        survey.admin_message.recipients_count
      end
      
      total_responses = SurveyResponse.where(survey: satisfaction_surveys).count
      
      return 0 if total_recipients.zero?
      ((total_responses.to_f / total_recipients) * 100).round(1)
    end
    
    def recent_satisfaction_comments(limit = 5)
      SurveyResponse.joins(:survey)
                    .where(surveys: { survey_type: 'satisfaction', active: true })
                    .where.not(answers: nil)
                    .order(created_at: :desc)
                    .limit(limit)
                    .map do |response|
                      answers = JSON.parse(response.answers || '{}')
                      {
                        score: response.satisfaction_score,
                        comment: answers['comment'],
                        date: response.created_at
                      }
                    end
                    .select { |r| r[:comment].present? }
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

    # Listings breakdown by sector with evolution
    def listings_by_sector_with_evolution
      sectors = Listing.industry_sectors.keys
      
      sectors.map do |sector|
        current_listings = Listing.where(industry_sector: sector)
                                  .where(validation_status: :approved)
                                  .where('created_at >= ?', @start_date)
                                  .count
        
        current_reservations = Deal.joins(:listing)
                                   .where(listings: { industry_sector: sector })
                                   .where(reserved: true)
                                   .where('deals.created_at >= ?', @start_date)
                                   .count
        
        current_transactions = Deal.joins(:listing)
                                   .where(listings: { industry_sector: sector })
                                   .where(status: :deal_signed)
                                   .where('deals.created_at >= ?', @start_date)
                                   .count

        # Previous period for evolution
        prev_start, prev_end = previous_period_dates
        prev_listings = Listing.where(industry_sector: sector)
                               .where(validation_status: :approved)
                               .where('created_at >= ? AND created_at < ?', prev_start, prev_end)
                               .count

        evolution = calculate_evolution_percentage(current_listings, prev_listings)
        conversion = current_listings > 0 ? ((current_transactions.to_f / current_listings) * 100).round(1) : 0

        {
          sector: I18n.t("listing.sectors.#{sector}", default: sector.humanize),
          listings: current_listings,
          reservations: current_reservations,
          transactions: current_transactions,
          conversion: "#{conversion}%",
          evolution: "#{evolution >= 0 ? '+' : ''}#{evolution}%"
        }
      end
    end

    # Listings breakdown by revenue range
    def listings_by_revenue_range
      ranges = [
        { label: '0 - 100k €', min: 0, max: 100_000 },
        { label: '100k - 250k €', min: 100_000, max: 250_000 },
        { label: '250k - 500k €', min: 250_000, max: 500_000 },
        { label: '500k - 1M €', min: 500_000, max: 1_000_000 },
        { label: '1M+ €', min: 1_000_000, max: nil }
      ]

      ranges.map do |range|
        # Build query based on whether there's a max value
        listings_scope = Listing.where(validation_status: :approved)
                                .where('created_at >= ?', @start_date)
        
        listings_scope = if range[:max]
                          listings_scope.where('annual_revenue >= ? AND annual_revenue < ?', range[:min], range[:max])
                        else
                          listings_scope.where('annual_revenue >= ?', range[:min])
                        end
        
        current_listings = listings_scope.count

        # Current reservations
        deals_scope = Deal.joins(:listing)
                          .where(reserved: true)
                          .where('deals.created_at >= ?', @start_date)
        
        deals_scope = if range[:max]
                        deals_scope.where('listings.annual_revenue >= ? AND listings.annual_revenue < ?', range[:min], range[:max])
                      else
                        deals_scope.where('listings.annual_revenue >= ?', range[:min])
                      end
        
        current_reservations = deals_scope.count

        # Current transactions
        transactions_scope = Deal.joins(:listing)
                                 .where(status: :deal_signed)
                                 .where('deals.created_at >= ?', @start_date)
        
        transactions_scope = if range[:max]
                               transactions_scope.where('listings.annual_revenue >= ? AND listings.annual_revenue < ?', range[:min], range[:max])
                             else
                               transactions_scope.where('listings.annual_revenue >= ?', range[:min])
                             end
        
        current_transactions = transactions_scope.count

        # Previous period
        prev_start, prev_end = previous_period_dates
        prev_scope = Listing.where(validation_status: :approved)
                            .where('created_at >= ? AND created_at < ?', prev_start, prev_end)
        
        prev_scope = if range[:max]
                       prev_scope.where('annual_revenue >= ? AND annual_revenue < ?', range[:min], range[:max])
                     else
                       prev_scope.where('annual_revenue >= ?', range[:min])
                     end
        
        prev_listings = prev_scope.count

        evolution = calculate_evolution_percentage(current_listings, prev_listings)

        {
          range: range[:label],
          listings: current_listings,
          reservations: current_reservations,
          transactions: current_transactions,
          evolution: "#{evolution >= 0 ? '+' : ''}#{evolution}%"
        }
      end
    end

    # Listings breakdown by geography (department/region)
    def listings_by_geography
      departments = Listing.where(validation_status: :approved)
                           .where('created_at >= ?', @start_date)
                           .where.not(location_department: nil)
                           .group(:location_department)
                           .count
                           .sort_by { |_, count| -count }
                           .first(10)

      departments.map do |department, current_count|
        current_reservations = Deal.joins(:listing)
                                   .where(listings: { location_department: department })
                                   .where(reserved: true)
                                   .where('deals.created_at >= ?', @start_date)
                                   .count

        current_transactions = Deal.joins(:listing)
                                   .where(listings: { location_department: department })
                                   .where(status: :deal_signed)
                                   .where('deals.created_at >= ?', @start_date)
                                   .count

        # Previous period
        prev_start, prev_end = previous_period_dates
        prev_count = Listing.where(validation_status: :approved)
                            .where(location_department: department)
                            .where('created_at >= ? AND created_at < ?', prev_start, prev_end)
                            .count

        evolution = calculate_evolution_percentage(current_count, prev_count)

        {
          department: department,
          listings: current_count,
          reservations: current_reservations,
          transactions: current_transactions,
          evolution: "#{evolution >= 0 ? '+' : ''}#{evolution}%"
        }
      end
    end

    # Listings breakdown by employee count
    def listings_by_employee_count
      ranges = [
        { label: '1 - 5', min: 1, max: 5 },
        { label: '6 - 10', min: 6, max: 10 },
        { label: '11 - 20', min: 11, max: 20 },
        { label: '21 - 50', min: 21, max: 50 },
        { label: '50+', min: 50, max: nil }
      ]

      ranges.map do |range|
        # Build query based on whether there's a max value
        listings_scope = Listing.where(validation_status: :approved)
                                .where('created_at >= ?', @start_date)
        
        listings_scope = if range[:max]
                          listings_scope.where('employee_count >= ? AND employee_count <= ?', range[:min], range[:max])
                        else
                          listings_scope.where('employee_count >= ?', range[:min])
                        end
        
        current_listings = listings_scope.count

        # Current reservations
        deals_scope = Deal.joins(:listing)
                          .where(reserved: true)
                          .where('deals.created_at >= ?', @start_date)
        
        deals_scope = if range[:max]
                        deals_scope.where('listings.employee_count >= ? AND listings.employee_count <= ?', range[:min], range[:max])
                      else
                        deals_scope.where('listings.employee_count >= ?', range[:min])
                      end
        
        current_reservations = deals_scope.count

        # Current transactions
        transactions_scope = Deal.joins(:listing)
                                 .where(status: :deal_signed)
                                 .where('deals.created_at >= ?', @start_date)
        
        transactions_scope = if range[:max]
                               transactions_scope.where('listings.employee_count >= ? AND listings.employee_count <= ?', range[:min], range[:max])
                             else
                               transactions_scope.where('listings.employee_count >= ?', range[:min])
                             end
        
        current_transactions = transactions_scope.count

        # Previous period
        prev_start, prev_end = previous_period_dates
        prev_scope = Listing.where(validation_status: :approved)
                            .where('created_at >= ? AND created_at < ?', prev_start, prev_end)
        
        prev_scope = if range[:max]
                       prev_scope.where('employee_count >= ? AND employee_count <= ?', range[:min], range[:max])
                     else
                       prev_scope.where('employee_count >= ?', range[:min])
                     end
        
        prev_listings = prev_scope.count

        evolution = calculate_evolution_percentage(current_listings, prev_listings)

        {
          range: "#{range[:label]} employés",
          listings: current_listings,
          reservations: current_reservations,
          transactions: current_transactions,
          evolution: "#{evolution >= 0 ? '+' : ''}#{evolution}%"
        }
      end
    end

    # Time series data for charts
    def time_series_data(metric: :listings, periods: 8)
      duration_days = (@end_date - @start_date).to_i
      days_per_period = [duration_days / periods, 1].max
      
      result = []
      periods.times do |i|
        period_start = @start_date + (i * days_per_period).days
        period_end = period_start + days_per_period.days

        value = case metric
                when :listings
                  Listing.where(validation_status: :approved)
                         .where(created_at: period_start..period_end)
                         .count
                when :reservations
                  Deal.where(reserved: true)
                      .where(reserved_at: period_start..period_end)
                      .count
                when :transactions
                  Deal.where(status: :deal_signed)
                      .where(created_at: period_start..period_end)
                      .count
                when :revenue
                  # Simplified revenue calculation
                  BuyerProfile.where(subscription_status: :active)
                              .where(created_at: period_start..period_end)
                              .count * 89
                else
                  0
                end

        result << {
          period: period_start.strftime('%d/%m'),
          value: value
        }
      end

      result
    end

    # Analytics Dashboard Methods

    # Average time spent in each CRM status with max limits
    def average_time_by_crm_status
      statuses = {
        'favorites' => { max: nil, unit: 'jours' },
        'to_contact' => { max: 7, unit: 'jours' },
        'info_exchange' => { max: 33, unit: 'jours' },
        'analysis' => { max: 33, unit: 'jours' },
        'project_alignment' => { max: 33, unit: 'jours' },
        'negotiation' => { max: 20, unit: 'jours' },
        'loi' => { max: nil, unit: 'jours' },
        'audits' => { max: nil, unit: 'jours' },
        'financing' => { max: nil, unit: 'jours' },
        'deal_signed' => { max: nil, unit: 'jours' }
      }

      statuses.map do |status, config|
        deals = Deal.where(status: status).where.not(stage_entered_at: nil)
        
        avg_days = if deals.any?
                     deals.average(:time_in_stage).to_f / 86400 # Convert seconds to days
                   else
                     0
                   end

        {
          name: I18n.t("deal.statuses.#{status}", default: status.humanize),
          avg: avg_days.round(1),
          max: config[:max],
          unit: config[:unit]
        }
      end
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

    def calculate_evolution_percentage(current, previous)
      if previous.zero?
        current.zero? ? 0 : 100
      else
        ((current - previous).to_f / previous * 100).round(0)
      end
    end
  end
end
