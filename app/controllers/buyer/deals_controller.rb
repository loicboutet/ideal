# frozen_string_literal: true

module Buyer
  class DealsController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile
    before_action :set_deal, only: [:show, :edit, :update, :move_stage, :release]

    def index
      # Get all active deals (not released)
      @deals = @buyer_profile.deals
                             .active
                             .includes(:listing)
                             .order(created_at: :desc)
      
      # Separate by status for display
      @favorited_deals = @deals.where(status: :favorited)
      @reserved_deals = @deals.where(reserved: true)
      @expiring_soon = @reserved_deals.select { |deal| deal.days_remaining && deal.days_remaining <= 3 }
    end

    def show
      @enrichments = @deal.enrichments.order(created_at: :desc)
      @history_events = @deal.deal_history_events.order(created_at: :desc)
    end

    def move_stage
      new_status = params[:new_status]
      
      if @deal.update(status: new_status, stage_entered_at: Time.current)
        redirect_to buyer_deal_path(@deal), notice: "Dossier déplacé vers l'étape: #{deal_stage_name(new_status)}"
      else
        redirect_to buyer_deal_path(@deal), alert: "Impossible de déplacer le dossier."
      end
    end

    private

    def set_buyer_profile
      @buyer_profile = current_user.buyer_profile
      
      unless @buyer_profile
        redirect_to root_path, alert: "Vous devez avoir un profil repreneur pour accéder à cette page."
      end
    end

    def set_deal
      @deal = @buyer_profile.deals.find(params[:id])
    end

    def ensure_buyer!
      unless current_user&.buyer?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
  end
end
