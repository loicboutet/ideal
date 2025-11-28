class PagesController < ApplicationController
  layout "mockup"

  def index
  end

  def about
  end

  def how_it_works
  end

  def pricing
    # Determine which plans to show based on user role
    if user_signed_in?
      @user_role = current_user.role
      @all_plans = SUBSCRIPTION_PLANS[@user_role.to_sym] || SUBSCRIPTION_PLANS[:buyer]
    else
      @user_role = 'buyer' # Default to buyer for non-logged-in users
      @all_plans = SUBSCRIPTION_PLANS[:buyer]
    end
  end

  def contact
  end

  def privacy
  end

  def terms
  end

  def submit_contact
    # Extract form parameters
    contact_params = {
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
      phone: params[:phone],
      user_type: params[:user_type],
      subject: params[:subject],
      message: params[:message],
      newsletter: params[:newsletter] == '1'
    }

    # Send email
    ContactMailer.contact_message(contact_params).deliver_later

    # Set flash message
    flash[:notice] = "Merci pour votre message ! Nous vous répondrons dans les plus brefs délais."
    
    # Redirect back to contact page
    redirect_to contact_path
  rescue => e
    Rails.logger.error "Contact form error: #{e.message}"
    flash[:alert] = "Une erreur s'est produite lors de l'envoi de votre message. Veuillez réessayer."
    redirect_to contact_path
  end
end
