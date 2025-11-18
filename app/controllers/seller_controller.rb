# Base controller for all Seller namespace controllers
class SellerController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role
  before_action :ensure_active_status
  before_action :ensure_nda_signed
  
  protected
  
  # Ensure current user has seller role
  def ensure_seller_role
    unless current_user&.seller?
      redirect_to root_path, alert: "Accès refusé. Compte vendeur requis."
    end
  end
  
  # Ensure current user account is active
  def ensure_active_status
    unless current_user&.active?
      redirect_to root_path, alert: "Votre compte n'est pas actif."
    end
  end
  
  # Ensure seller has signed the platform NDA
  def ensure_nda_signed
    unless current_user.nda_signatures.platform_nda.signed.exists?
      redirect_to seller_nda_path, alert: "Vous devez signer l'accord de confidentialité pour accéder à cette section."
    end
  end
  
  # Get current seller's profile
  def current_seller_profile
    @current_seller_profile ||= current_user.seller_profile
  end
  helper_method :current_seller_profile
  
  # Get current seller's listings
  def current_seller_listings
    @current_seller_listings ||= current_seller_profile&.listings || Listing.none
  end
  helper_method :current_seller_listings
  
  private
  
  # Redirect after successful seller actions
  def after_action_redirect_path
    seller_root_path
  end
end
