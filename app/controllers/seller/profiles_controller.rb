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
    if @profile.update(profile_params)
      redirect_to seller_profile_path, notice: 'Votre profil a été mis à jour avec succès.'
    else
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
  
  def profile_params
    params.require(:seller_profile).permit(
      :is_broker,
      :receive_signed_nda
    )
  end
end
