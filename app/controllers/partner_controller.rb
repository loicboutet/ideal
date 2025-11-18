# Base controller for all Partner namespace controllers
class PartnerController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_partner_role
  before_action :ensure_active_status
  before_action :ensure_partner_approved
  before_action :check_directory_subscription, except: [:subscription]
  
  protected
  
  # Ensure current user has partner role
  def ensure_partner_role
    unless current_user&.partner?
      redirect_to root_path, alert: "Accès refusé. Compte partenaire requis."
    end
  end
  
  # Ensure current user account is active
  def ensure_active_status
    unless current_user&.active?
      redirect_to root_path, alert: "Votre compte n'est pas actif."
    end
  end
  
  # Ensure partner profile has been approved by admin
  def ensure_partner_approved
    unless current_partner_profile&.approved?
      redirect_to root_path, alert: "Votre profil partenaire est en attente d'approbation."
    end
  end
  
  # Check if partner has active directory subscription
  def check_directory_subscription
    return if request.path.include?('subscription')
    
    unless partner_has_directory_access?
      redirect_to partner_subscription_path, 
                  alert: "Un abonnement annuaire est requis pour accéder à cette fonctionnalité."
    end
  end
  
  # Get current partner's profile
  def current_partner_profile
    @current_partner_profile ||= current_user.partner_profile
  end
  helper_method :current_partner_profile
  
  # Check if partner has active directory subscription
  def partner_has_directory_access?
    current_user.subscriptions.directory.active.exists?
  end
  helper_method :partner_has_directory_access?
  
  # Get partner's contact requests/leads
  def partner_contacts
    @partner_contacts ||= current_partner_profile&.partner_contacts || PartnerContact.none
  end
  helper_method :partner_contacts
  
  # Check partner's visibility in directory
  def directory_visible?
    current_partner_profile&.directory_visible? && partner_has_directory_access?
  end
  helper_method :directory_visible?
  
  private
  
  # Redirect after successful partner actions
  def after_action_redirect_path
    partner_root_path
  end
end
