class Seller::InterestsController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_seller_profile

  # GET /seller/interests
  # Shows buyers who have favorited the seller's listings
  def index
    @interests = collect_interested_buyers
    
    @stats = {
      total_interested: @interests.count,
      this_week: @interests.count { |i| i[:favorited_at] >= 7.days.ago },
      active_negotiations: count_active_negotiations
    }
  end

  # GET /seller/interests/:id
  # Shows details of a specific interested buyer
  def show
    @buyer_profile = BuyerProfile.find(params[:id])
    @favorites = Favorite.where(buyer_profile: @buyer_profile)
                         .joins(:listing)
                         .where(listings: { seller_profile_id: @seller_profile.id })
                         .includes(:listing)
                         .order(created_at: :desc)
    
    @deals = Deal.where(buyer_profile: @buyer_profile)
                 .joins(:listing)
                 .where(listings: { seller_profile_id: @seller_profile.id })
                 .includes(:listing)
                 .order(updated_at: :desc)
    
    @can_contact = @seller_profile.credits >= 5 || @seller_profile.subscription_plan == 'premium'
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

  def collect_interested_buyers
    # Get all buyer profiles who have favorited seller's listings
    listing_ids = @seller_profile.listings.pluck(:id)
    
    Favorite.where(listing_id: listing_ids)
            .includes(buyer_profile: :user, listing: [])
            .group_by(&:buyer_profile)
            .map do |buyer_profile, favorites|
              {
                buyer_profile: buyer_profile,
                favorites_count: favorites.count,
                listings: favorites.map(&:listing),
                favorited_at: favorites.map(&:created_at).max,
                has_deal: Deal.exists?(buyer_profile: buyer_profile, listing_id: listing_ids)
              }
            end
            .sort_by { |i| -i[:favorited_at].to_i }
  end

  def count_active_negotiations
    listing_ids = @seller_profile.listings.pluck(:id)
    Deal.where(listing_id: listing_ids)
        .where(status: [:negociation, :loi, :audits, :financement])
        .count
  end
end
