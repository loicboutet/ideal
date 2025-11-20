class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # Use custom layout for Devise controllers
  layout :layout_by_resource
  
  # Set user cookie for Action Cable authentication
  before_action :set_action_cable_identifier

  # Redirect to role-based dashboard after sign in
  def after_sign_in_path_for(resource)
    case resource.role
    when 'admin'
      admin_root_path
    when 'seller'
      seller_root_path
    when 'buyer'
      buyer_root_path
    when 'partner'
      partner_root_path
    else
      root_path
    end
  end

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
  
  # Set user ID in cookies for Action Cable authentication
  def set_action_cable_identifier
    cookies.encrypted[:user_id] = current_user&.id
  end

  # Custom layout for Devise and namespaced controllers
  def layout_by_resource
    if devise_controller?
      "devise"
    else
      # Detect namespace and use corresponding layout
      controller_namespace = self.class.name.split('::').first
      
      case controller_namespace
      when 'Admin'
        'admin'
      when 'Buyer'
        'buyer'
      when 'Seller'
        'seller'
      when 'Partner'
        'partner'
      else
        'application'
      end
    end
  end
end
