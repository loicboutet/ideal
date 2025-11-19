class Partner::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_partner!
  before_action :set_profile
  
  def show
    @profile = current_user.partner_profile
  end
  
  def edit
    @profile = current_user.partner_profile
  end
  
  def update
    if @profile.update(profile_params)
      flash.now[:notice] = 'Votre profil a été mis à jour avec succès.'
      render :edit
    else
      flash.now[:alert] = 'Erreur lors de la mise à jour du profil. Veuillez vérifier les champs.'
      render :edit, status: :unprocessable_entity
    end
  end
  
  def preview
    @profile = current_user.partner_profile
    render :show
  end
  
  private
  
  def set_profile
    @profile = current_user.partner_profile
    
    unless @profile
      redirect_to partner_root_path, alert: 'Veuillez créer votre profil partenaire.'
    end
  end
  
  def require_partner!
    unless current_user.partner?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end
  
  def profile_params
    params.require(:partner_profile).permit(
      :partner_type,
      :description,
      :services_offered,
      :calendar_link,
      :website,
      :coverage_area,
      :coverage_details,
      intervention_stages: [],
      industry_specializations: []
    )
  end
end
