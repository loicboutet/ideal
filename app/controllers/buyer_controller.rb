# Base controller for all Buyer namespace controllers
class BuyerController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role
  before_action :ensure_active_status
  before_action :ensure_nda_signed
  before_action :check_subscription_access, except: [:subscription]
  
  protected
  
  # Ensure current user has buyer role
  def ensure_buyer_role
    unless current_user&.buyer?
      redirect_to root_path, alert: "Accès refusé. Compte repreneur requis."
    end
  end
  
  # Ensure current user account is active
  def ensure_active_status
    unless current_user&.active?
      redirect_to root_path, alert: "Votre compte n'est pas actif."
    end
  end
  
  # Ensure buyer has signed the platform NDA
  def ensure_nda_signed
    unless current_user.nda_signatures.platform_nda.signed.exists?
      redirect_to buyer_nda_path, alert: "Vous devez signer l'accord de confidentialité pour accéder à cette section."
    end
  end
  
  # Check if buyer has active subscription or credits for premium features
  def check_subscription_access
    return if request.path.include?('subscription') || request.path.include?('upgrade')
    
    unless buyer_has_access?
      redirect_to buyer_subscription_path, 
                  alert: "Un abonnement ou des crédits sont requis pour accéder à cette fonctionnalité."
    end
  end
  
  # Get current buyer's profile
  def current_buyer_profile
    @current_buyer_profile ||= current_user.buyer_profile
  end
  helper_method :current_buyer_profile
  
  # Get current buyer's deals
  def current_buyer_deals
    @current_buyer_deals ||= current_buyer_profile&.deals || Deal.none
  end
  helper_method :current_buyer_deals
  
  # Get current buyer's favorites
  def current_buyer_favorites
    @current_buyer_favorites ||= current_buyer_profile&.favorites || Favorite.none
  end
  helper_method :current_buyer_favorites
  
  # Check if buyer has access to premium features
  def buyer_has_access?
    current_user.subscriptions.active.exists? || current_buyer_profile&.credits&.positive?
  end
  helper_method :buyer_has_access?
  
  # Check if buyer can reserve more listings (based on plan limits)
  def can_reserve_listing?
    # Free users: limited reservations, Paid users: more/unlimited
    return false unless buyer_has_access?
    
    active_reservations = current_buyer_deals.reserved.count
    subscription = current_user.subscriptions.active.first
    
    return true if subscription&.plan == 'premium' # Unlimited
    return active_reservations < 5 if subscription&.plan == 'standard'
    return active_reservations < 2 # Starter plan or credit-based
  end
  helper_method :can_reserve_listing?
  
  private
  
  # Redirect after successful buyer actions
  def after_action_redirect_path
    buyer_root_path
  end
end
