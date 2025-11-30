# frozen_string_literal: true

# Public ListingsController
# Handles public (unauthenticated) listing browsing - critical for freemium model
# Users can browse/search listings without signing in, but need account for full details
class ListingsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:index, :show, :search]
  before_action :set_listing, only: [:show]
  
  # Use the mockup layout for public pages (consistent styling)
  layout 'mockup'
  
  # GET /listings
  # Public listing browse - freemium access point
  def index
    @listings = base_listings_scope
    
    # Apply filters
    apply_filters
    
    # Sorting
    apply_sorting
    
    # Stats for header
    @stats = calculate_stats
    
    # Pagination (manual since we're not using Kaminari in mockups)
    @page = (params[:page] || 1).to_i
    @per_page = 12
    @total_count = @listings.count
    @listings = @listings.offset((@page - 1) * @per_page).limit(@per_page)
    @total_pages = (@total_count.to_f / @per_page).ceil
  end
  
  # GET /listings/:id
  # Public listing detail - shows limited info, paywall for full details
  def show
    # Track view (anonymously if not signed in)
    track_listing_view
    
    # Get similar listings for sidebar
    @similar_listings = similar_listings
  end
  
  # GET /listings/search
  # Advanced search page with more filter options
  def search
    @listings = base_listings_scope
    
    # Apply all filters including advanced ones
    apply_filters
    apply_advanced_filters
    
    # Sorting
    apply_sorting
    
    # Active filters for display
    @active_filters = build_active_filters
    
    # Pagination
    @page = (params[:page] || 1).to_i
    @per_page = 10
    @total_count = @listings.count
    @listings = @listings.offset((@page - 1) * @per_page).limit(@per_page)
    @total_pages = (@total_count.to_f / @per_page).ceil
  end
  
  private
  
  def set_listing
    @listing = Listing.where(status: :published, validation_status: :approved)
                      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Annonce introuvable ou non disponible."
    redirect_to listings_path
  end
  
  # Base scope: only published and approved listings
  def base_listings_scope
    Listing.where(status: :published, validation_status: :approved)
           .includes(:seller_profile)
           .order(published_at: :desc)
  end
  
  # Apply basic filters from index page
  def apply_filters
    # Sector filter
    if params[:sector].present?
      @listings = @listings.where(industry_sector: params[:sector])
    end
    
    # Price range filter
    if params[:min_price].present?
      @listings = @listings.where('asking_price >= ?', params[:min_price].to_i)
    end
    if params[:max_price].present?
      @listings = @listings.where('asking_price <= ?', params[:max_price].to_i)
    end
    
    # Location filter (department or city)
    if params[:location].present?
      location_term = "%#{params[:location].downcase}%"
      @listings = @listings.where(
        'LOWER(location_city) LIKE ? OR LOWER(location_department) LIKE ? OR LOWER(location_region) LIKE ?',
        location_term, location_term, location_term
      )
    end
    
    # Revenue range filter
    if params[:min_revenue].present?
      @listings = @listings.where('annual_revenue >= ?', params[:min_revenue].to_i)
    end
    if params[:max_revenue].present?
      @listings = @listings.where('annual_revenue <= ?', params[:max_revenue].to_i)
    end
    
    # Keyword search (title and public description)
    if params[:q].present?
      search_term = "%#{params[:q].downcase}%"
      @listings = @listings.where(
        'LOWER(title) LIKE ? OR LOWER(description_public) LIKE ?',
        search_term, search_term
      )
    end
  end
  
  # Apply advanced filters from search page
  def apply_advanced_filters
    # Company age filter
    if params[:company_age].present?
      case params[:company_age]
      when 'less_than_2'
        @listings = @listings.where('founded_year > ?', 2.years.ago.year)
      when '2_to_5'
        @listings = @listings.where('founded_year BETWEEN ? AND ?', 5.years.ago.year, 2.years.ago.year)
      when '5_to_10'
        @listings = @listings.where('founded_year BETWEEN ? AND ?', 10.years.ago.year, 5.years.ago.year)
      when '10_to_20'
        @listings = @listings.where('founded_year BETWEEN ? AND ?', 20.years.ago.year, 10.years.ago.year)
      when 'more_than_20'
        @listings = @listings.where('founded_year < ?', 20.years.ago.year)
      end
    end
    
    # Employee count filter
    if params[:employees].present?
      case params[:employees]
      when '0'
        @listings = @listings.where(employee_count: 0)
      when '1_5'
        @listings = @listings.where(employee_count: 1..5)
      when '6_10'
        @listings = @listings.where(employee_count: 6..10)
      when '11_20'
        @listings = @listings.where(employee_count: 11..20)
      when '21_50'
        @listings = @listings.where(employee_count: 21..50)
      when 'more_than_50'
        @listings = @listings.where('employee_count > ?', 50)
      end
    end
    
    # Legal form filter
    if params[:legal_forms].present?
      @listings = @listings.where(legal_form: params[:legal_forms])
    end
    
    # Transfer type filter
    if params[:transfer_type].present?
      @listings = @listings.where(transfer_type: params[:transfer_type])
    end
  end
  
  # Apply sorting
  def apply_sorting
    case params[:sort]
    when 'price_asc'
      @listings = @listings.reorder(asking_price: :asc)
    when 'price_desc'
      @listings = @listings.reorder(asking_price: :desc)
    when 'revenue_asc'
      @listings = @listings.reorder(annual_revenue: :asc)
    when 'revenue_desc'
      @listings = @listings.reorder(annual_revenue: :desc)
    when 'oldest'
      @listings = @listings.reorder(published_at: :asc)
    else # 'newest' or default
      @listings = @listings.reorder(published_at: :desc)
    end
  end
  
  # Calculate stats for the index page header
  def calculate_stats
    published_listings = Listing.where(status: :published, validation_status: :approved)
    
    {
      total: published_listings.count,
      new_this_month: published_listings.where('published_at >= ?', 30.days.ago).count,
      avg_price: calculate_average_price(published_listings),
      sector_count: published_listings.select(:industry_sector).distinct.count
    }
  end
  
  def calculate_average_price(listings)
    avg = listings.where.not(asking_price: nil).average(:asking_price)
    return '0' unless avg
    
    if avg >= 1_000_000
      "#{(avg / 1_000_000.0).round(1)}M"
    elsif avg >= 1_000
      "#{(avg / 1_000.0).round(0)}k"
    else
      avg.round(0).to_s
    end
  end
  
  # Track listing view for analytics
  def track_listing_view
    # Use the model's track_view! method if available
    if @listing.respond_to?(:track_view!)
      @listing.track_view!(
        user: current_user,
        ip_address: request.remote_ip
      )
    else
      # Fallback: just increment the counter
      @listing.increment!(:views_count) if @listing.respond_to?(:views_count)
    end
  rescue StandardError => e
    # Don't fail the page load if tracking fails
    Rails.logger.warn "Failed to track listing view: #{e.message}"
  end
  
  # Get similar listings for the show page sidebar
  def similar_listings
    Listing.where(status: :published, validation_status: :approved)
           .where(industry_sector: @listing.industry_sector)
           .where.not(id: @listing.id)
           .limit(3)
           .order(published_at: :desc)
  end
  
  # Build active filters hash for display in search results
  def build_active_filters
    filters = []
    
    filters << { key: 'sector', label: sector_label(params[:sector]), value: params[:sector] } if params[:sector].present?
    filters << { key: 'location', label: params[:location], value: params[:location] } if params[:location].present?
    
    if params[:min_price].present? || params[:max_price].present?
      price_label = format_price_range(params[:min_price], params[:max_price])
      filters << { key: 'price', label: price_label, value: "#{params[:min_price]}-#{params[:max_price]}" }
    end
    
    if params[:min_revenue].present? || params[:max_revenue].present?
      revenue_label = format_price_range(params[:min_revenue], params[:max_revenue], 'CA')
      filters << { key: 'revenue', label: revenue_label, value: "#{params[:min_revenue]}-#{params[:max_revenue]}" }
    end
    
    filters << { key: 'q', label: "\"#{params[:q]}\"", value: params[:q] } if params[:q].present?
    
    filters
  end
  
  def sector_label(sector)
    return nil unless sector
    I18n.t("enums.listing.industry_sector.#{sector}", default: sector.to_s.humanize)
  end
  
  def format_price_range(min, max, prefix = '')
    return nil unless min.present? || max.present?
    
    min_str = min.present? ? format_currency(min.to_i) : '0'
    max_str = max.present? ? format_currency(max.to_i) : '∞'
    
    "#{prefix}#{prefix.present? ? ' ' : ''}#{min_str} - #{max_str}"
  end
  
  def format_currency(amount)
    if amount >= 1_000_000
      "#{(amount / 1_000_000.0).round(1)}M €"
    elsif amount >= 1_000
      "#{(amount / 1_000.0).round(0)}k €"
    else
      "#{amount} €"
    end
  end
end
