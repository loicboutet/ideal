# frozen_string_literal: true

module Admin
  class ListingsController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_listing, only: [:show, :edit, :update, :destroy, :validate, :reject]

    def index
      @listings = Listing.includes(:seller_profile).order(created_at: :desc)

      # Apply filters
      if params[:status].present? && params[:status] != 'all'
        @listings = @listings.where(status: params[:status])
      end

      if params[:validation_status].present? && params[:validation_status] != 'all'
        @listings = @listings.where(validation_status: params[:validation_status])
      end

      if params[:sector].present? && params[:sector] != 'all'
        @listings = @listings.where(industry_sector: params[:sector])
      end

      # Apply search
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @listings = @listings.where(
          "title LIKE ? OR description_public LIKE ? OR location_city LIKE ?",
          search_term, search_term, search_term
        )
      end

      @stats = {
        total: Listing.count,
        pending: Listing.pending_validation.count,
        approved: Listing.approved_listings.count,
        rejected: Listing.rejected_listings.count
      }
    end

    def pending
      @listings = Listing.includes(:seller_profile)
                        .pending_validation
                        .order(created_at: :asc) # Oldest first for validation queue
    end

    def show
      @seller = @listing.seller_profile.user
      
      # Get stats
      @stats = {
        views: @listing.views_count,
        favorites: @listing.favorites.count,
        reservations: @listing.deals.where(reserved: true).count,
        abandons: @listing.deals.where(status: :released).count,
        completeness: @listing.calculate_completeness
      }
    end

    def new
      @listing = Listing.new
      @sellers = User.where(role: :seller).order(:email)
    end

    def create
      seller_profile = SellerProfile.find(params[:listing][:seller_profile_id])
      @listing = seller_profile.listings.build(listing_params)
      
      if @listing.save
        redirect_to admin_listing_path(@listing), notice: "Annonce créée avec succès."
      else
        @sellers = User.where(role: :seller).order(:email)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @sellers = User.where(role: :seller).order(:email)
    end

    def update
      if @listing.update(listing_params)
        redirect_to admin_listing_path(@listing), notice: "Annonce mise à jour avec succès."
      else
        @sellers = User.where(role: :seller).order(:email)
        render :edit, status: :unprocessable_entity
      end
    end

    def validate
      @listing.validation_status = :approved
      @listing.validated_at = Time.current
      @listing.validation_comment = params[:comment] if params[:comment].present?
      
      # Optional: Attribute deal to specific buyer
      if params[:attributed_buyer_id].present?
        @listing.attributed_buyer_id = params[:attributed_buyer_id]
      end
      
      if @listing.save
        # Publish listing if not already
        @listing.update(status: :published, published_at: Time.current) unless @listing.published?
        
        redirect_to admin_listing_path(@listing), notice: "Annonce validée et publiée avec succès."
      else
        redirect_to admin_listing_path(@listing), alert: "Erreur lors de la validation."
      end
    end

    def reject
      @listing.validation_status = :rejected
      @listing.validated_at = Time.current
      @listing.validation_comment = params[:comment]
      
      if @listing.save
        redirect_to admin_listing_path(@listing), notice: "Annonce rejetée. Le vendeur a été notifié."
      else
        redirect_to admin_listing_path(@listing), alert: "Erreur lors du rejet."
      end
    end

    def destroy
      @listing.destroy
      redirect_to admin_listings_path, notice: "Annonce supprimée avec succès."
    end

    private

    def set_listing
      @listing = Listing.find(params[:id])
    end

    def ensure_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def listing_params
      params.require(:listing).permit(
        :seller_profile_id, :title, :description_public, :description_confidential,
        :industry_sector, :deal_type, :location_department, :location_city,
        :location_region, :annual_revenue, :employee_count, :net_profit,
        :asking_price, :price_min, :price_max, :transfer_horizon, :transfer_type,
        :company_age, :customer_type, :legal_form, :website,
        :show_scorecard_stars, :scorecard_stars
      )
    end
  end
end
