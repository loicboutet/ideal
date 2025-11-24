# frozen_string_literal: true

module Buyer
  class ListingsController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile
    before_action :set_listing, only: [:show, :favorite, :unfavorite, :reserve, :release, :release_confirm]

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

      # Track view with user and IP information
      @listing.track_view!(user: current_user, ip_address: request.remote_ip)
      
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

    def matches
      # Use matching service to find listings that match buyer's criteria
      matcher = Buyer::ListingMatcherService.new(@buyer_profile)
      @matches = matcher.find_matches(limit: params[:limit]&.to_i)
      
      # Paginate results (already sorted by score)
      per_page = 20
      page = (params[:page] || 1).to_i
      offset = (page - 1) * per_page
      
      @total_matches = @matches.count
      @matches = @matches[offset, per_page] || []
      @current_page = page
      @total_pages = (@total_matches.to_f / per_page).ceil
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

    def reserve
      # Check if listing can be reserved
      unless @listing.can_be_reserved_by?(@buyer_profile)
        redirect_to buyer_listing_path(@listing), alert: "Cette annonce ne peut pas être réservée."
        return
      end

      # Check platform NDA is signed
      platform_nda_signed = current_user.nda_signatures.exists?(signature_type: :platform_wide)
      unless platform_nda_signed
        redirect_to buyer_nda_path, alert: "Vous devez d'abord signer l'accord de confidentialité plateforme."
        return
      end

      # Check listing-specific NDA is signed
      listing_nda_signed = current_user.nda_signatures.exists?(signature_type: :listing_specific, listing_id: @listing.id)
      unless listing_nda_signed
        redirect_to buyer_listing_path(@listing), alert: "Vous devez signer l'accord de confidentialité spécifique à cette annonce."
        return
      end

      # Find or create deal
      @deal = @buyer_profile.deals.find_or_initialize_by(listing_id: @listing.id, released_at: nil)
      
      if @deal.new_record?
        @deal.status = :to_contact
        @deal.stage_entered_at = Time.current
      end

      # Reserve the deal
      @deal.reserve!

      # Update listing status to reserved
      @listing.update(status: :reserved)

      # Create notification
      Notification.create!(
        user: current_user,
        notification_type: :deal_reserved,
        title: "Annonce réservée avec succès",
        message: "L'annonce '#{@listing.title}' a été réservée. Vous avez #{@deal.days_remaining} jours pour progresser.",
        link_url: buyer_deal_path(@deal)
      )

      redirect_to buyer_listing_path(@listing), notice: "✅ Annonce réservée avec succès ! Vous avez #{@deal.days_remaining} jours pour cette étape."
    end

    def release
      # Find active deal
      @deal = @buyer_profile.deals.find_by(listing_id: @listing.id, released_at: nil)
      
      unless @deal
        redirect_to buyer_listing_path(@listing), alert: "Aucune réservation active pour cette annonce."
        return
      end

      # Calculate credits before releasing
      credits_earned = @deal.calculate_release_credits

      # Release the deal
      @deal.release!(params[:release_reason])

      # Update buyer credits
      @buyer_profile.increment!(:credits, credits_earned)

      # Update listing status back to published
      @listing.update(status: :published)

      # Create notification
      Notification.create!(
        user: current_user,
        notification_type: :deal_released,
        title: "Annonce libérée",
        message: "Vous avez libéré l'annonce '#{@listing.title}' et gagné #{credits_earned} crédit(s).",
        link_url: buyer_credits_path
      )

      redirect_to buyer_listings_path, notice: "✅ Annonce libérée avec succès ! Vous avez gagné #{credits_earned} crédit(s)."
    end

    def release_confirm
      # Find active deal
      @deal = @buyer_profile.deals.find_by(listing_id: @listing.id, released_at: nil)
      
      unless @deal
        redirect_to buyer_listing_path(@listing), alert: "Aucune réservation active pour cette annonce."
        return
      end

      # Calculate potential credits
      @credits_to_earn = @deal.calculate_release_credits
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

    def calculate_release_credits
      base_credit = 1
      doc_credits = @deal.enrichments.where(validated: true).count
      base_credit + doc_credits
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
