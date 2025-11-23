class Partner::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_partner!
  before_action :set_profile
  
  def show
    @profile = current_user.partner_profile
  end
  
  def edit
    current_user.reload
    @profile = current_user.partner_profile
  end
  
  def update
    # Update user's company name if provided
    if params[:user].present? && params[:user][:company_name].present?
      current_user.update(company_name: params[:user][:company_name])
    end
    
    if @profile.update(profile_params)
      redirect_to edit_partner_profile_path, notice: 'Votre profil a été mis à jour avec succès.'
    else
      @profile.reload
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
