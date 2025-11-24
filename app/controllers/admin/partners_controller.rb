# frozen_string_literal: true

module Admin
  class PartnersController < ApplicationController
    layout 'admin'
    
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_partner, only: [:show, :approve, :reject]

    def index
      @partners = PartnerProfile.includes(:user)
                                .order(created_at: :desc)

      # Apply filters
      if params[:partner_type].present? && params[:partner_type] != 'all'
        @partners = @partners.where(partner_type: params[:partner_type])
      end

      if params[:validation_status].present? && params[:validation_status] != 'all'
        @partners = @partners.where(validation_status: params[:validation_status])
      end

      # Apply pagination
      @partners = @partners.page(params[:page]).per(20)

      # Stats
      @stats = {
        total: PartnerProfile.count,
        pending: PartnerProfile.where(validation_status: :pending).count,
        approved: PartnerProfile.where(validation_status: :approved).count,
        rejected: PartnerProfile.where(validation_status: :rejected).count
      }
    end

    def pending
      @partners = PartnerProfile.includes(:user)
                                .where(validation_status: :pending)
                                .order(created_at: :asc) # Oldest first for validation queue
    end

    def show
      @user = @partner.user
    end

    def approve
      @partner.validation_status = :approved
      @partner.validated_at = Time.current
      
      if @partner.save
        # Send approval notification email
        PartnerMailer.profile_approved(@partner).deliver_later
        
        redirect_to admin_partners_path, notice: "Partenaire #{@partner.user.email} approuvé avec succès."
      else
        redirect_to admin_partner_path(@partner), alert: "Erreur lors de l'approbation."
      end
    end

    def reject
      @partner.validation_status = :rejected
      @partner.validated_at = Time.current
      reason = params[:reason].presence || params[:partner_profile]&.dig(:rejection_reason)
      @partner.rejection_reason = reason if reason.present?
      
      if @partner.save
        # Send rejection notification email
        PartnerMailer.profile_rejected(@partner, reason).deliver_later
        
        redirect_to admin_partners_path, notice: "Partenaire #{@partner.user.email} rejeté."
      else
        redirect_to admin_partner_path(@partner), alert: "Erreur lors du rejet."
      end
    end

    private

    def set_partner
      @partner = PartnerProfile.find(params[:id])
    end

    def ensure_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
  end
end
