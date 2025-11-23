# frozen_string_literal: true

module Admin
  class DealsController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_deal, only: [:show, :update, :assign_form, :assign_exclusive]

    def index
      @deals = Deal.includes(:buyer_profile, :listing)
                   .order(created_at: :desc)

      # Apply filters
      @deals = @deals.where(status: params[:status]) if params[:status].present? && params[:status] != 'all'
      @deals = @deals.where(reserved: true) if params[:reserved] == 'true'
      @deals = @deals.active if params[:active] == 'true'

      # Apply search
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @deals = @deals.joins(:listing, buyer_profile: :user)
                       .where(
                         "listings.title LIKE ? OR users.email LIKE ? OR users.first_name LIKE ? OR users.last_name LIKE ?",
                         search_term, search_term, search_term, search_term
                       )
      end

      @deals = @deals.page(params[:page]).per(20) if defined?(Kaminari)
    end

    def show
      @deal_history = @deal.deal_history_events.order(created_at: :desc)
      @buyer = @deal.buyer_profile.user
      @seller = @deal.listing.seller_profile.user
      @listing = @deal.listing
    end

    def update
      if @deal.update(deal_params)
        redirect_to admin_deal_path(@deal), notice: "Affaire mise à jour avec succès."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def assign_form
      @buyers = User.includes(:buyer_profile)
                    .where(role: :buyer, status: :active)
                    .where.not(buyer_profiles: { id: nil })
                    .order(:first_name, :last_name)
      @listing = @deal.listing
    end

    def assign_exclusive
      buyer_profile = BuyerProfile.find(params[:buyer_profile_id])
      
      # Create or find existing deal for this buyer and listing
      deal = Deal.find_or_initialize_by(
        buyer_profile: buyer_profile,
        listing: @deal.listing
      )
      
      if deal.new_record?
        deal.status = :to_contact
        deal.reserved = true
        deal.reserved_at = Time.current
        deal.reserved_until = 7.days.from_now
      end
      
      if deal.save
        # Create notification for buyer
        Notification.create!(
          user: buyer_profile.user,
          notification_type: :exclusive_deal_assigned,
          title: "Affaire exclusive assignée",
          message: "Une affaire exclusive vous a été assignée par l'administrateur: #{@deal.listing.title}",
          link_url: "/buyer/deals/#{deal.id}"
        )
        
        redirect_to admin_deal_path(@deal), notice: "Affaire assignée avec succès à #{buyer_profile.user.full_name}."
      else
        redirect_to assign_form_admin_deal_path(@deal), alert: "Erreur lors de l'assignation de l'affaire."
      end
    end

    private

    def set_deal
      @deal = Deal.includes(:buyer_profile, :listing).find(params[:id])
    end

    def ensure_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def deal_params
      params.require(:deal).permit(:status, :reserved)
    end
  end
end
