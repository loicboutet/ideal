class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  protect_from_forgery with: :exception
  
  # Devise configuration
  before_action :authenticate_user!, except: [:index, :show, :search] # Allow public access to some pages
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Global error handling
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::RoutingError, with: :handle_not_found
  rescue_from ActionController::UnknownFormat, with: :handle_not_found
  rescue_from AbstractController::ActionNotFound, with: :handle_not_found

  rescue_from StandardError, with: :handle_server_error if Rails.env.production?

  # Public action for catch-all route
  def render_404
    handle_not_found
  end

  protected

  # Devise: Configure permitted parameters for registration/account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  # Devise: Redirect users after sign in based on their role
  def after_sign_in_path_for(resource)
    return admin_root_path if resource.admin?
    return seller_root_path if resource.seller?
    return buyer_root_path if resource.buyer?
    return partner_root_path if resource.partner?
    
    root_path # Fallback
  end

  # Devise: Redirect users after sign up based on their role
  def after_sign_up_path_for(resource)
    case resource.role
    when 'admin'
      admin_root_path
    when 'seller'
      seller_nda_path # Sellers need to sign NDA first
    when 'buyer'
      buyer_profile_path # Buyers need to complete profile
    when 'partner'
      partner_profile_path # Partners need to complete profile for approval
    else
      root_path
    end
  end

  # Role-based authorization helpers
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès refusé. Privilèges administrateur requis."
    end
  end

  def require_seller!
    unless current_user&.seller?
      redirect_to root_path, alert: "Accès refusé. Compte vendeur requis."
    end
  end

  def require_buyer!
    unless current_user&.buyer?
      redirect_to root_path, alert: "Accès refusé. Compte repreneur requis."
    end
  end

  def require_partner!
    unless current_user&.partner?
      redirect_to root_path, alert: "Accès refusé. Compte partenaire requis."
    end
  end

  # Check if user account is active
  def require_active_account!
    unless current_user&.active?
      redirect_to root_path, alert: "Votre compte n'est pas actif. Contactez l'administration."
    end
  end

  # Helper methods available in views
  helper_method :current_user_role, :user_signed_in_with_role?, :user_has_profile?

  def current_user_role
    current_user&.role
  end

  def user_signed_in_with_role?(role)
    user_signed_in? && current_user.role == role.to_s
  end

  def user_has_profile?
    return false unless current_user
    current_user.profile.present?
  end

  private

  def handle_not_found
    respond_to do |format|
      format.html { render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.all { render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false }
    end
  end

  def handle_forbidden
    respond_to do |format|
      format.html { render file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false }
      format.json { render json: { error: 'Forbidden' }, status: :forbidden }
      format.all { render file: Rails.root.join('public', '403.html'), status: :forbidden, layout: false }
    end
  end

  def handle_server_error(exception = nil)
    # Log the error for debugging
    Rails.logger.error "Internal Server Error: #{exception.message}" if exception
    Rails.logger.error exception.backtrace.join("\n") if exception

    respond_to do |format|
      format.html { render file: Rails.root.join('public', '500.html'), status: :internal_server_error, layout: false }
      format.json { render json: { error: 'Internal Server Error' }, status: :internal_server_error }
      format.all { render file: Rails.root.join('public', '500.html'), status: :internal_server_error, layout: false }
    end
  end

  # Deprecated - kept for backward compatibility, use handle_not_found instead
  alias_method :render_not_found, :handle_not_found
  alias_method :render_forbidden, :handle_forbidden
  alias_method :render_server_error, :handle_server_error

  # Helper method to raise 404 manually when needed
  def not_found!
    raise ActionController::RoutingError, 'Not Found'
  end
end
