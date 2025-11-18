class Seller::BuyersController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!
  before_action :set_buyer, only: [:show]

  def index
    # Start with published buyer profiles only
    @buyers = BuyerProfile.published_profiles.includes(:user)
    
    # Apply filters
    if params[:sector].present? && params[:sector] != 'all'
      @buyers = @buyers.where("target_sectors LIKE ?", "%#{params[:sector]}%")
    end
    
    if params[:location].present? && params[:location] != 'all'
      @buyers = @buyers.where("target_locations LIKE ?", "%#{params[:location]}%")
    end
    
    if params[:subscription].present? && params[:subscription] != 'all'
      @buyers = @buyers.where(subscription_plan: params[:subscription])
    end
    
    # Search
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @buyers = @buyers.joins(:user).where(
        "users.first_name LIKE ? OR buyer_profiles.skills LIKE ? OR buyer_profiles.investment_thesis LIKE ?",
        search_term, search_term, search_term
      )
    end
    
    # Order by completeness and subscription level
    @buyers = @buyers.order(verified_buyer: :desc, completeness_score: :desc, created_at: :desc)
    
    # Pagination (12 per page)
    @buyers = @buyers.page(params[:page]).per(12)
    
    # Stats for the view
    @total_buyers = BuyerProfile.published_profiles.count
  end

  def show
    # Show detailed buyer profile (public data only)
    @buyer_id = @buyer.id
  end

  def search
    # Advanced search page (can be implemented later)
    redirect_to seller_buyers_path, notice: 'Utilisez les filtres pour affiner votre recherche.'
  end

  private

  def set_buyer
    @buyer = BuyerProfile.published_profiles.includes(:user).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_buyers_path, alert: 'Profil de repreneur introuvable.'
  end

  def authorize_seller!
    unless current_user&.seller_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de cédant requis.'
    end
  end
end
