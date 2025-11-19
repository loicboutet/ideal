class Seller::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_seller!
  before_action :set_profile
  
  def show
    @profile = current_user.seller_profile
    @active_listings = @profile.listings.where(status: [:active, :pending])
    
    # Load interested buyers count for each listing
    @listings_with_interests = @active_listings.includes(:deals).map do |listing|
      {
        listing: listing,
        interested_count: listing.deals.where(status: [:initial_contact, :nda_signed, :loi_stage, :audit_stage]).count
      }
    end
    
    # Calculate statistics for last 30 days
    @stats = {
      profile_views: @profile.profile_views_count,
      contacts_received: @profile.profile_contacts_count,
      active_mandates: @profile.active_mandates_count,
      pushes_sent: @profile.monthly_pushes_count
    }
  end
  
  def edit
    @profile = current_user.seller_profile
  end
  
  def update
    # Update user attributes first
    user_updated = current_user.update(user_params) if params[:seller_profile][:user_attributes].present?
    
    # Update profile attributes
    profile_updated = @profile.update(profile_params)
    
    if (user_updated != false) && profile_updated
      flash.now[:notice] = 'Votre profil a été mis à jour avec succès.'
      render :edit
    else
      # Collect all error messages
      @errors = []
      @errors.concat(current_user.errors.full_messages) if current_user.errors.any?
      @errors.concat(@profile.errors.full_messages) if @profile.errors.any?
      
      flash.now[:alert] = 'Erreur lors de la mise à jour du profil. Veuillez vérifier les champs.'
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_profile
    @profile = current_user.seller_profile
    
    unless @profile
      # Create profile if doesn't exist
      @profile = current_user.create_seller_profile!
    end
  end
  
  def require_seller!
    unless current_user.seller?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end
  
  def user_params
    return {} unless params[:seller_profile][:user_attributes].present?
    
    params.require(:seller_profile).require(:user_attributes).permit(
      :first_name,
      :last_name,
      :phone,
      :company_name
    )
  end
  
  def profile_params
    permitted_params = [
      :receive_signed_nda
    ]
    
    # Add broker-specific fields if user is a broker
    if current_user.seller_profile&.is_broker
      permitted_params += [
        :siret_number,
        :specialization,
        :calendar_link,
        intervention_zones: [],
        specialization_sectors: [],
        intervention_stages: []
      ]
    end
    
    params.require(:seller_profile).permit(*permitted_params)
  end
end
