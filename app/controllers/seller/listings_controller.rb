class Seller::ListingsController < ApplicationController
  include SubscriptionGate
  
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :analytics, :push_to_buyer]
  before_action :check_listing_limit, only: [:create]
  before_action :check_push_ability, only: [:push_to_buyer]

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
    
    # Get listing analytics
    @analytics = @listing.analytics
    @views_count = @listing.views_count
    @interested_count = @analytics.interested_buyers_count
    @crm_stage = @analytics.current_crm_stage
    @crm_progress = @analytics.crm_progress_percentage
  end

  def new
    @listing = current_user.seller_profile.listings.build
    
    # Check if user is at listing limit and set a flag for the view
    current_count = current_user.seller_profile.listings.count
    max_listings = current_user.feature_limit(:max_listings) || 3
    @at_listing_limit = !current_user.has_plan?(:premium) && current_count >= max_listings
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
    buyer_profile = BuyerProfile.find(params[:buyer_profile_id])
    seller_profile = current_user.seller_profile
    
    # Check if listing is approved
    unless @listing.validation_status == 'approved'
      redirect_to seller_buyer_path(buyer_profile), 
                  alert: 'Seules les annonces approuvées peuvent être proposées.'
      return
    end
    
    # Try to create the push (credit deduction handled by model callback)
    listing_push = ListingPush.new(
      listing: @listing,
      buyer_profile: buyer_profile,
      seller_profile: seller_profile
    )
    
    if listing_push.save
      # Create notification for buyer
      create_push_notification(buyer_profile, @listing)
      
      redirect_to seller_buyer_path(buyer_profile), 
                  notice: "Annonce \"#{@listing.title}\" proposée à #{buyer_profile.user.first_name}. 1 crédit déduit."
    else
      redirect_to seller_buyer_path(buyer_profile), 
                  alert: listing_push.errors.full_messages.first || 'Une erreur est survenue.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_buyers_path, alert: 'Repreneur introuvable.'
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
  
  def create_push_notification(buyer_profile, listing)
    Notification.create(
      user: buyer_profile.user,
      notification_type: :listing_pushed,
      title: 'Nouvelle annonce suggérée',
      message: "Un cédant vous a proposé l'annonce \"#{listing.title}\" qui pourrait correspondre à vos critères de recherche.",
      link_url: "/buyer/listings/#{listing.id}"
    )
  rescue => e
    Rails.logger.error "Failed to create push notification: #{e.message}"
  end
  
  def check_listing_limit
    # Premium sellers have unlimited listings
    return if current_user.has_plan?(:premium)
    
    # Free sellers limited to 3 listings
    current_count = current_user.seller_profile.listings.count
    max_listings = current_user.feature_limit(:max_listings) || 3
    
    if current_count >= max_listings
      redirect_to seller_listings_path,
                  alert: "Vous avez atteint la limite de #{max_listings} annonces. Passez au forfait Premium pour des annonces illimitées."
    end
  end
  
  def check_push_ability
    # Check if user can push (either has premium with quota or has credits)
    unless current_user.can_push_listing?
      if current_user.has_plan?(:premium)
        # Premium user exceeded monthly quota
        redirect_to seller_buyer_path(params[:buyer_profile_id]),
                    alert: "Vous avez atteint votre quota mensuel de 5 mises en avant."
      else
        # Free user needs credits
        redirect_to seller_credits_path,
                    alert: "Vous avez besoin de 1 crédit pour proposer cette annonce."
      end
    end
  end
end
