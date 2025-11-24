class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /inscription/en-attente
  def pending_approval
    unless current_user&.partner? && current_user&.pending?
      redirect_to root_path and return
    end
  end

  # POST /users (registration)
  def create
    build_resource(sign_up_params)
    
    # Set status based on role
    resource.status = resource.role == 'partner' ? :pending : :active
    
    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, 
      :last_name, 
      :phone, 
      :role,
      :company_name,
      :buyer_type,
      :partner_type
    ])
  end

  def after_sign_up_path_for(resource)
    case resource.role
    when 'seller'
      seller_root_path
    when 'buyer'
      buyer_profile_path # Will redirect to profile wizard
    when 'partner'
      pending_approval_users_registrations_path
    else
      root_path
    end
  end

  def after_inactive_sign_up_path_for(resource)
    if resource.partner?
      pending_approval_users_registrations_path
    else
      root_path
    end
  end
end
