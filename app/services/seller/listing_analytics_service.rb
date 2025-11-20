# frozen_string_literal: true

module Seller
  class ListingAnalyticsService
    def initialize(listing)
      @listing = listing
    end

    # Get total views count
    def total_views
      @listing.listing_views.count
    end

    # Get unique viewers count
    def unique_viewers
      @listing.listing_views.where.not(user_id: nil).distinct.count(:user_id)
    end

    # Get interested buyers count (who favorited or reserved)
    def interested_buyers_count
      favorited_count = @listing.favorites.count
      reserved_count = @listing.deals.where.not(status: :released).count
      
      # Get unique buyer_profile_ids from both favorites and deals
      favorited_buyer_ids = @listing.favorites.pluck(:buyer_profile_id)
      reserved_buyer_ids = @listing.deals.where.not(status: :released).pluck(:buyer_profile_id)
      
      (favorited_buyer_ids + reserved_buyer_ids).uniq.count
    end

    # Get views trend for a period
    def views_trend(days: 30)
      end_date = Time.current
      start_date = end_date - days.days
      
      @listing.listing_views
              .where(viewed_at: start_date..end_date)
              .group_by_day(:viewed_at, range: start_date..end_date)
              .count
    end

    # Get views growth percentage
    def views_growth_percentage(days: 30)
      current_period = @listing.listing_views
                               .where(viewed_at: days.days.ago..Time.current)
                               .count
      
      previous_period = @listing.listing_views
                                .where(viewed_at: (days * 2).days.ago..days.days.ago)
                                .count
      
      return 0 if previous_period.zero?
      
      ((current_period - previous_period).to_f / previous_period * 100).round(1)
    end

    # Get CRM stage distribution for this listing's deals
    def crm_stage_distribution
      @listing.deals.group(:status).count
    end

    # Get current CRM stage for the most advanced buyer
    def current_crm_stage
      most_advanced_deal = @listing.deals
                                   .where.not(status: :released)
                                   .order(status: :desc)
                                   .first
      
      most_advanced_deal&.status || :no_activity
    end

    # Get CRM progress percentage (0-100)
    def crm_progress_percentage
      stage_mapping = {
        favorited: 10,
        to_contact: 20,
        info_exchange: 35,
        analysis: 50,
        project_alignment: 60,
        negotiation: 75,
        loi: 85,
        audits: 90,
        financing: 95,
        deal_signed: 100,
        released: 0
      }
      
      stage = current_crm_stage
      stage_mapping[stage.to_sym] || 0
    end

    # Get interested buyers with their details
    def interested_buyers
      # Get buyers who favorited
      favorited_buyers = @listing.favorites.includes(buyer_profile: :user).map do |favorite|
        {
          buyer_profile: favorite.buyer_profile,
          user: favorite.buyer_profile.user,
          interest_type: :favorited,
          date: favorite.created_at
        }
      end

      # Get buyers who reserved/have deals
      deal_buyers = @listing.deals.where.not(status: :released)
                            .includes(buyer_profile: :user)
                            .map do |deal|
        {
          buyer_profile: deal.buyer_profile,
          user: deal.buyer_profile.user,
          interest_type: :reserved,
          date: deal.created_at,
          crm_stage: deal.status
        }
      end

      # Merge and deduplicate by buyer_profile_id
      all_buyers = (favorited_buyers + deal_buyers)
      all_buyers.uniq { |b| b[:buyer_profile].id }
                .sort_by { |b| b[:date] }
                .reverse
    end

    # Get analytics summary for dashboard
    def self.summary_for_seller(seller_profile)
      listings = seller_profile.listings.where(status: [:active, :published])
      
      {
        total_views: listings.sum(:views_count),
        total_interested: listings.sum { |l| new(l).interested_buyers_count },
        total_listings: listings.count,
        avg_completion: listings.average(:completeness_score)&.round || 0
      }
    end

    # Get per-listing analytics for dashboard
    def self.listings_with_analytics(seller_profile)
      seller_profile.listings.includes(:favorites, :deals).map do |listing|
        service = new(listing)
        {
          listing: listing,
          views: listing.views_count,
          interested: service.interested_buyers_count,
          completion: listing.completeness_score,
          crm_stage: service.current_crm_stage,
          crm_progress: service.crm_progress_percentage
        }
      end
    end
  end
end
