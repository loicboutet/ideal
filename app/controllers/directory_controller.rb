# frozen_string_literal: true

# Public DirectoryController
# Handles public partner directory browsing - partners paying for visibility need public exposure
class DirectoryController < ApplicationController
  before_action :set_partner, only: [:show]
  
  # Use the mockup layout for public pages (consistent styling)
  layout 'mockup'
  
  # GET /partners
  # Public partner directory browse
  def index
    @partners = base_partners_scope
    
    # Apply filters
    apply_filters
    
    # Sorting
    apply_sorting
    
    # Stats for display
    @stats = calculate_stats
    
    # Pagination
    @page = (params[:page] || 1).to_i
    @per_page = 12
    @total_count = @partners.count
    @partners = @partners.offset((@page - 1) * @per_page).limit(@per_page)
    @total_pages = (@total_count.to_f / @per_page).ceil
  end
  
  # GET /partners/:id
  # Public partner profile detail
  def show
    # Track view for partner analytics
    @partner.increment_views! if @partner.respond_to?(:increment_views!)
    
    # Get related partners (same type, different profile)
    @related_partners = related_partners
  end
  
  # GET /partners/search
  # Advanced search with more filter options
  def search
    @partners = base_partners_scope
    
    # Apply all filters
    apply_filters
    apply_advanced_filters
    
    # Sorting
    apply_sorting
    
    # Active filters for display
    @active_filters = build_active_filters
    
    # Pagination
    @page = (params[:page] || 1).to_i
    @per_page = 10
    @total_count = @partners.count
    @partners = @partners.offset((@page - 1) * @per_page).limit(@per_page)
    @total_pages = (@total_count.to_f / @per_page).ceil
  end
  
  private
  
  def set_partner
    @partner = PartnerProfile.approved
                             .active_subscription
                             .includes(:user)
                             .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Partenaire introuvable ou non disponible."
    redirect_to partners_path
  end
  
  # Base scope: only approved partners with active subscription
  def base_partners_scope
    PartnerProfile.approved
                  .active_subscription
                  .includes(:user)
                  .order(created_at: :desc)
  end
  
  # Check if a column exists on the model
  def column_exists?(column_name)
    PartnerProfile.column_names.include?(column_name.to_s)
  end
  
  # Apply basic filters
  def apply_filters
    # Partner type filter
    if params[:type].present?
      @partners = @partners.where(partner_type: params[:type])
    end
    
    # Location filter (city, department, or region) - only if columns exist
    if params[:location].present?
      location_term = "%#{params[:location].downcase}%"
      conditions = []
      conditions << "LOWER(city) LIKE '#{location_term}'" if column_exists?(:city)
      conditions << "LOWER(department) LIKE '#{location_term}'" if column_exists?(:department)
      conditions << "LOWER(coverage_details) LIKE '#{location_term}'" if column_exists?(:coverage_details)
      
      if conditions.any?
        @partners = @partners.where(conditions.join(' OR '))
      end
    end
    
    # Coverage area filter
    if params[:coverage].present? && column_exists?(:coverage_area)
      @partners = @partners.where(coverage_area: params[:coverage])
    end
    
    # Keyword search
    if params[:q].present?
      search_term = "%#{params[:q].downcase}%"
      @partners = @partners.joins(:user).where(
        'LOWER(partner_profiles.description) LIKE ? OR LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?',
        search_term, search_term, search_term
      )
    end
  end
  
  # Apply advanced filters from search page
  def apply_advanced_filters
    # Premium only filter - only if column exists
    if params[:premium] == '1' && column_exists?(:is_premium)
      @partners = @partners.where(is_premium: true)
    end
    
    # Minimum rating filter (if rating system exists)
    if params[:min_rating].present? && column_exists?(:average_rating)
      min_rating = params[:min_rating].to_f
      @partners = @partners.where('average_rating >= ?', min_rating)
    end
    
    # Intervention stages filter
    if params[:stages].present? && column_exists?(:intervention_stages)
      stages = Array(params[:stages])
      stages.each do |stage|
        @partners = @partners.where("intervention_stages LIKE ?", "%#{stage}%")
      end
    end
    
    # Industry specialization filter
    if params[:industries].present? && column_exists?(:industry_specializations)
      industries = Array(params[:industries])
      industries.each do |industry|
        @partners = @partners.where("industry_specializations LIKE ?", "%#{industry}%")
      end
    end
  end
  
  # Apply sorting
  def apply_sorting
    case params[:sort]
    when 'name'
      @partners = @partners.joins(:user).reorder('users.last_name ASC')
    when 'rating'
      if column_exists?(:average_rating)
        @partners = @partners.reorder(average_rating: :desc)
      else
        @partners = @partners.reorder(created_at: :desc)
      end
    when 'views'
      if column_exists?(:views_count)
        @partners = @partners.reorder(views_count: :desc)
      else
        @partners = @partners.reorder(created_at: :desc)
      end
    when 'recent'
      @partners = @partners.reorder(created_at: :desc)
    else # 'relevance' or default
      if column_exists?(:views_count)
        @partners = @partners.reorder(views_count: :desc, created_at: :desc)
      else
        @partners = @partners.reorder(created_at: :desc)
      end
    end
  end
  
  # Calculate stats for display
  def calculate_stats
    all_partners = PartnerProfile.approved.active_subscription
    
    stats = {
      total: all_partners.count,
      lawyers: all_partners.where(partner_type: :lawyer).count,
      accountants: all_partners.where(partner_type: :accountant).count,
      consultants: all_partners.where(partner_type: :consultant).count,
      regions: 0
    }
    
    # Only count regions if column exists
    if column_exists?(:coverage_area)
      stats[:regions] = all_partners.select(:coverage_area).distinct.count
    end
    
    stats
  end
  
  # Get related partners for show page
  def related_partners
    scope = PartnerProfile.approved
                          .active_subscription
                          .where(partner_type: @partner.partner_type)
                          .where.not(id: @partner.id)
                          .includes(:user)
                          .limit(3)
    
    if column_exists?(:views_count)
      scope.order(views_count: :desc)
    else
      scope.order(created_at: :desc)
    end
  end
  
  # Build active filters hash for display
  def build_active_filters
    filters = []
    
    filters << { key: 'type', label: partner_type_label(params[:type]), value: params[:type] } if params[:type].present?
    filters << { key: 'location', label: params[:location], value: params[:location] } if params[:location].present?
    filters << { key: 'coverage', label: coverage_label(params[:coverage]), value: params[:coverage] } if params[:coverage].present?
    filters << { key: 'q', label: "\"#{params[:q]}\"", value: params[:q] } if params[:q].present?
    filters << { key: 'premium', label: 'Premium', value: '1' } if params[:premium] == '1'
    
    filters
  end
  
  def partner_type_label(type)
    labels = {
      'lawyer' => 'Avocat',
      'accountant' => 'Expert-comptable',
      'consultant' => 'Consultant',
      'banker' => 'Banquier',
      'broker' => 'Courtier',
      'other' => 'Autre'
    }
    labels[type] || type&.humanize
  end
  
  def coverage_label(coverage)
    labels = {
      'city' => 'Ville',
      'department' => 'Département',
      'region' => 'Région',
      'nationwide' => 'France entière',
      'international' => 'International'
    }
    labels[coverage] || coverage&.humanize
  end
end
