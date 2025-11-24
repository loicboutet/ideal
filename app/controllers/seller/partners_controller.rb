class Seller::PartnersController < ApplicationController
  include SubscriptionGate
  
  before_action :authenticate_user!
  before_action :require_seller!
  before_action :check_partner_contact_ability, only: [:contact]
  layout 'seller'

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
    
    # Check if user has free access (first 6 months)
    @has_free_access = has_free_directory_access?
    @credits_required = 5
  end

  def show
    @partner = PartnerProfile.approved.find(params[:id])
    @user = @partner.user

    # Track view
    @partner.increment_views!

    # Check if user can contact
    @can_contact = can_contact_partner?
    @credits_required = 5
  end

  def contact
    @partner = PartnerProfile.approved.find(params[:id])
    
    # Create contact record
    contact = PartnerContact.create!(
      partner_profile: @partner,
      user: current_user,
      contact_type: :directory_contact
    )

    # Deduct credits if not in free period (using credit service)
    unless has_free_directory_access?
      begin
        Payment::CreditService.deduct_partner_contact_credits(current_user, contact)
      rescue Payment::CreditService::InsufficientCreditsError => e
        contact.destroy
        redirect_to seller_credits_path, 
                    alert: "Crédits insuffisants. Il vous faut 5 crédits pour contacter un partenaire."
        return
      end
    end

    # Increment contact counter
    @partner.increment_contacts!

    # Create notification for partner
    Notification.create!(
      user: @partner.user,
      notification_type: :partner_contacted,
      title: "Nouveau contact",
      message: "#{current_user.company_name || current_user.full_name} souhaite vous contacter",
      link_url: partner_profile_path
    )

    redirect_to seller_partner_path(@partner), notice: "Demande de contact envoyée avec succès."
  end

  private

  def require_seller!
    unless current_user.seller?
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

  def has_free_directory_access?
    # Free access for first 6 months after seller registration
    return false unless current_user.seller_profile
    
    six_months_ago = 6.months.ago
    current_user.created_at > six_months_ago
  end

  def can_contact_partner?
    # Use the User model method
    current_user.can_contact_partner?
  end
  
  def check_partner_contact_ability
    unless can_contact_partner?
      redirect_to seller_credits_path,
                  alert: "Vous avez besoin de 5 crédits pour contacter un partenaire."
    end
  end
end
