class Buyer::PartnersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_buyer!
  layout 'buyer'

  def index
    @partners = PartnerProfile.approved
                              .includes(:user)
                              .order(created_at: :desc)

    # Apply filters
    apply_filters

    # Pagination
    @partners = @partners.page(params[:page]).per(12)

    # Stats for display
    @total_partners = PartnerProfile.approved.count
    @partner_types_count = PartnerProfile.approved.group(:partner_type).count
  end

  def show
    @partner = PartnerProfile.approved.find(params[:id])
    @user = @partner.user

    # Track view
    @partner.increment_views!

    # Check if user can contact (subscriber or has credits)
    @can_contact = can_contact_partner?
  end

  def contact
    @partner = PartnerProfile.approved.find(params[:id])
    
    # Check access
    unless can_contact_partner?
      redirect_to buyer_partners_path, alert: "Vous devez être abonné ou avoir des crédits pour contacter un partenaire."
      return
    end

    # Create contact record
    contact = PartnerContact.create!(
      partner_profile: @partner,
      user: current_user,
      contact_type: :directory_contact
    )

    # Increment contact counter
    @partner.increment_contacts!

    # Create notification for partner
    Notification.create!(
      user: @partner.user,
      notification_type: :partner_contacted,
      title: "Nouveau contact",
      message: "#{current_user.full_name} souhaite vous contacter",
      link_url: partner_profile_path
    )

    # Deduct credit if not subscriber (for non-free period)
    unless current_user.buyer_profile&.subscription_status == 'active'
      # TODO: Implement credit deduction when credit system is active
    end

    redirect_to buyer_partner_path(@partner), notice: "Demande de contact envoyée avec succès."
  end

  private

  def require_buyer!
    unless current_user.buyer?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end

  def apply_filters
    # Filter by partner type
    if params[:partner_type].present? && params[:partner_type] != 'all'
      @partners = @partners.where(partner_type: params[:partner_type])
    end

    # Filter by coverage area
    if params[:coverage_area].present? && params[:coverage_area] != 'all'
      @partners = @partners.where(coverage_area: params[:coverage_area])
    end

    # Filter by intervention stage
    if params[:intervention_stage].present?
      @partners = @partners.where("intervention_stages LIKE ?", "%#{params[:intervention_stage]}%")
    end

    # Filter by industry specialization
    if params[:industry].present?
      @partners = @partners.where("industry_specializations LIKE ?", "%#{params[:industry]}%")
    end

    # Search by name or description
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @partners = @partners.joins(:user).where(
        "users.company_name LIKE ? OR partner_profiles.description LIKE ? OR partner_profiles.services_offered LIKE ?",
        search_term, search_term, search_term
      )
    end
  end

  def can_contact_partner?
    # Free for active subscribers
    return true if current_user.buyer_profile&.subscription_status == 'active'
    
    # Otherwise requires credits (when credit system is implemented)
    # For now, allow contact
    true
  end
end
