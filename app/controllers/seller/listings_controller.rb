class Seller::ListingsController < ApplicationController
  layout 'mockup_seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :analytics, :push_to_buyer]

  def index
    @filter = params[:filter] || 'all'
    
    @listings = current_user.seller_profile.listings
    
    case @filter
    when 'pending'
      @listings = @listings.pending_validation
    when 'approved'
      @listings = @listings.approved_listings
    when 'rejected'
      @listings = @listings.rejected_listings
    when 'published'
      @listings = @listings.published_listings
    end
    
    @listings = @listings.order(created_at: :desc)
    
    # Stats for dashboard
    @stats = {
      total: current_user.seller_profile.listings.count,
      pending: current_user.seller_profile.listings.pending_validation.count,
      approved: current_user.seller_profile.listings.approved_listings.count,
      rejected: current_user.seller_profile.listings.rejected_listings.count
    }
  end

  def show
    # Show individual listing details
    @listing_id = @listing.id
  end

  def new
    @listing = current_user.seller_profile.listings.build
  end

  def create
    @listing = current_user.seller_profile.listings.build(listing_params)
    @listing.submitted_at = Time.current if params[:submit_for_validation]
    
    if @listing.save
      if params[:submit_for_validation]
        redirect_to seller_listings_path(filter: 'pending'), 
                    notice: 'Annonce créée et soumise pour validation.'
      else
        redirect_to seller_listing_path(@listing), 
                    notice: 'Annonce créée en tant que brouillon.'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Only allow editing if pending or rejected
    unless @listing.pending_validation? || @listing.validation_status == 'rejected'
      redirect_to seller_listing_path(@listing), 
                  alert: 'Les annonces approuvées ne peuvent pas être modifiées. Contactez l\'administrateur.'
      return
    end
  end

  def update
    # Only allow updating if pending or rejected
    unless @listing.pending_validation? || @listing.validation_status == 'rejected'
      redirect_to seller_listing_path(@listing), 
                  alert: 'Les annonces approuvées ne peuvent pas être modifiées.'
      return
    end
    
    if @listing.update(listing_params)
      @listing.update(submitted_at: Time.current) if params[:submit_for_validation]
      redirect_to seller_listing_path(@listing), notice: 'Annonce mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Only allow deletion of drafts
    if @listing.status == 'draft'
      @listing.destroy
      redirect_to seller_listings_path, notice: 'Annonce supprimée avec succès.'
    else
      redirect_to seller_listing_path(@listing), 
                  alert: 'Seuls les brouillons peuvent être supprimés.'
    end
  end

  def analytics
    # Load analytics data with period filtering
    @period = params[:period] || '30'
    @period_days = @period.to_i
    
    # Calculate date range
    @start_date = @period_days.days.ago
    @end_date = Time.current
    
    # Views data for graph
    @views_data = @listing.listing_views
      .where('created_at >= ?', @start_date)
      .group_by_day(:created_at)
      .count
    
    # Favorites data for graph
    @favorites_data = @listing.favorites
      .where('created_at >= ?', @start_date)
      .group_by_day(:created_at)
      .count
    
    # Buyers who favorited with profiles
    @interested_buyers = @listing.favorites
      .includes(buyer_profile: :user)
      .order(created_at: :desc)
    
    # Deals by CRM stage
    @deals_by_stage = @listing.deals.active.group(:status).count
    
    # Recent activity
    @recent_views = @listing.listing_views
      .includes(:user)
      .order(created_at: :desc)
      .limit(10)
  end

  def push_to_buyer
    # Push listing to specific buyer (costs credits)
    # Implementation to be added
    redirect_to seller_listing_path(@listing), 
                notice: 'Fonctionnalité bientôt disponible.'
  end

  private

  def set_listing
    @listing = current_user.seller_profile.listings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_listings_path, alert: 'Annonce introuvable.'
  end

  def authorize_seller!
    unless current_user&.seller_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de cédant requis.'
    end
  end

  def listing_params
    params.require(:listing).permit(
      :title, :description_public, :description_confidential,
      :industry_sector, :location_department, :location_region, :location_city,
      :annual_revenue, :employee_count, :net_profit,
      :asking_price, :price_min, :price_max,
      :transfer_horizon, :transfer_type, :company_age, :customer_type,
      :legal_form, :website, :deal_type, :show_scorecard_stars, :scorecard_stars
    )
  end
end
