# Base controller for all Admin namespace controllers
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_role
  before_action :ensure_active_status
  
  protected
  
  # Ensure current user has admin role
  def ensure_admin_role
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé. Privilèges administrateur requis."
    end
  end
  
  # Ensure current user account is active
  def ensure_active_status
    unless current_user&.active?
      redirect_to root_path, alert: "Votre compte n'est pas actif."
    end
  end
  
  # Set admin-specific layout and navigation
  def authorize_admin!
    ensure_admin_role
  end
  
  private
  
  # Redirect after successful admin actions
  def after_action_redirect_path
    admin_root_path
  end
end
