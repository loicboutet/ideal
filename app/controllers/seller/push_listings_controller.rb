class Seller::PushListingsController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_seller_profile

  # GET /seller/push_listings
  # Main page to push listings to interested buyers
  def index
    @credits = @seller_profile.credits || 0
    
    # Get listing IDs for this seller
    listing_ids = @seller_profile.listings.pluck(:id)
    
    # Get buyers who have favorited seller's listings
    @interested_buyers = Favorite.where(listing_id: listing_ids)
                                  .includes(buyer_profile: :user)
                                  .group_by(&:buyer_profile)
                                  .map do |buyer_profile, favorites|
      {
        buyer_profile: buyer_profile,
        favorites_count: favorites.count,
        listings: favorites.map(&:listing),
        subscription_plan: buyer_profile.subscription_plan
      }
    end
    
    # Get seller's active listings for selection
    @listings = @seller_profile.listings.where(status: :active)
  end

  # POST /seller/push_listings
  # Process push to selected buyers
  def create
    buyer_ids = params[:buyer_ids] || []
    listing_id = params[:listing_id]
    
    if buyer_ids.empty?
      redirect_to seller_push_listings_path, alert: 'Veuillez sélectionner au moins un repreneur.'
      return
    end
    
    credits_needed = buyer_ids.count
    
    if @seller_profile.credits < credits_needed
      redirect_to seller_push_listings_path, alert: "Crédits insuffisants. Vous avez #{@seller_profile.credits} crédits, il vous en faut #{credits_needed}."
      return
    end
    
    # Find the listing
    listing = @seller_profile.listings.find_by(id: listing_id)
    unless listing
      redirect_to seller_push_listings_path, alert: 'Annonce non trouvée.'
      return
    end
    
    # Process push to each buyer
    pushed_count = 0
    buyer_ids.each do |buyer_id|
      buyer_profile = BuyerProfile.find_by(id: buyer_id)
      next unless buyer_profile
      
      # Create a notification/push record (in real implementation)
      # For now, just count successful pushes
      pushed_count += 1
    end
    
    if pushed_count > 0
      # Deduct credits
      @seller_profile.update(credits: @seller_profile.credits - pushed_count)
      
      redirect_to seller_push_listings_path, notice: "Annonce poussée avec succès à #{pushed_count} repreneur(s). #{pushed_count} crédit(s) déduit(s)."
    else
      redirect_to seller_push_listings_path, alert: 'Aucun repreneur valide sélectionné.'
    end
  end

  private

  def authorize_seller!
    unless current_user&.seller? && current_user&.active?
      redirect_to root_path, alert: 'Accès refusé. Privilèges vendeur requis.'
    end
  end

  def set_seller_profile
    @seller_profile = current_user.seller_profile
    unless @seller_profile
      redirect_to root_path, alert: 'Profil vendeur non trouvé.'
    end
  end
end
