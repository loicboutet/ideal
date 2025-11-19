# frozen_string_literal: true

module Buyer
  class ListingsController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile
    before_action :set_listing, only: [:show, :favorite, :unfavorite]

    def index
      # Base query: approved, published listings available for this buyer
      @listings = Listing.approved
                        .published_listings
                        .available_for_buyer(@buyer_profile)
                        .includes(:seller_profile)
                        .order(created_at: :desc)

      # Apply filters
      apply_filters

      # Separate exclusive deals for this buyer
      @exclusive_listings = Listing.approved
                                  .published_listings
                                  .attributed_to(@buyer_profile)
                                  .includes(:seller_profile)
                                  .order(created_at: :desc)

      # Apply pagination
      @listings = @listings.page(params[:page]).per(20)
    end

    def show
      # Ensure buyer can only view listings available to them
      unless listing_available_to_buyer?
        redirect_to buyer_listings_path, alert: "Cette annonce n'est pas disponible."
        return
      end

      # Track view
      @listing.increment_views!
      
      # Check if buyer has favorited this listing
      @is_favorited = @buyer_profile.favorites.exists?(listing_id: @listing.id)
      
      # Check if buyer has an active deal
      @active_deal = @buyer_profile.deals.find_by(listing_id: @listing.id, released_at: nil)
      
      # Check if listing is exclusively attributed to this buyer
      @is_exclusive = @listing.attributed_buyer_id == @buyer_profile.id
    end

    def exclusive
      # Show only deals exclusively attributed to this buyer
      @exclusive_listings = Listing.approved
                                  .published_listings
                                  .attributed_to(@buyer_profile)
                                  .includes(:seller_profile)
                                  .order(created_at: :desc)
                                  .page(params[:page]).per(20)
      
      render :index
    end

    def favorite
      # Check if already favorited
      if @buyer_profile.favorites.exists?(listing_id: @listing.id)
        redirect_to buyer_listing_path(@listing), alert: "Cette annonce est déjà dans vos favoris."
        return
      end

      # Create favorite
      @favorite = @buyer_profile.favorites.create!(listing_id: @listing.id)

      # Auto-create deal with "favorited" status if no active deal exists
      unless @buyer_profile.deals.active.exists?(listing_id: @listing.id)
        @buyer_profile.deals.create!(
          listing_id: @listing.id,
          status: :favorited,
          stage_entered_at: Time.current
        )
      end

      redirect_to buyer_listing_path(@listing), notice: "✅ Annonce ajoutée aux favoris et à votre CRM."
    end

    def unfavorite
      @favorite = @buyer_profile.favorites.find_by(listing_id: @listing.id)
      
      unless @favorite
        redirect_to buyer_listing_path(@listing), alert: "Cette annonce n'est pas dans vos favoris."
        return
      end

      @favorite.destroy!
      redirect_to buyer_listing_path(@listing), notice: "Annonce retirée des favoris."
    end

    private

    def set_buyer_profile
      @buyer_profile = current_user.buyer_profile
      
      unless @buyer_profile
        redirect_to root_path, alert: "Vous devez avoir un profil repreneur pour accéder à cette page."
      end
    end

    def set_listing
      @listing = Listing.find(params[:id])
    end

    def ensure_buyer!
      unless current_user&.buyer?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def listing_available_to_buyer?
      # Listing must be either not attributed, or attributed to current buyer
      @listing.attributed_buyer_id.nil? || @listing.attributed_buyer_id == @buyer_profile.id
    end

    def apply_filters
      # Deal type filter
      if params[:deal_type].present? && params[:deal_type] != 'all'
        @listings = @listings.where(deal_type: params[:deal_type])
      end

      # Sector filter
      if params[:sector].present? && params[:sector] != 'all'
        @listings = @listings.where(industry_sector: params[:sector])
      end

      # Location filter
      if params[:department].present?
        @listings = @listings.where(location_department: params[:department])
      end

      # Price range filter
      if params[:price_min].present?
        @listings = @listings.where('asking_price >= ?', params[:price_min])
      end
      
      if params[:price_max].present?
        @listings = @listings.where('asking_price <= ?', params[:price_max])
      end

      # Revenue range filter
      if params[:revenue_min].present?
        @listings = @listings.where('annual_revenue >= ?', params[:revenue_min])
      end
      
      if params[:revenue_max].present?
        @listings = @listings.where('annual_revenue <= ?', params[:revenue_max])
      end

      # Search
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @listings = @listings.where(
          "title LIKE ? OR description_public LIKE ?",
          search_term, search_term
        )
      end
    end
  end
end
