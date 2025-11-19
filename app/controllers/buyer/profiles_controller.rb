class Buyer::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_buyer!
  before_action :set_profile, except: [:new, :create]
  
  def show
    @profile = current_user.buyer_profile
    
    # Calculate completeness if not set
    if @profile.completeness_score.zero?
      @profile.update_completeness!
    end
  end
  
  def new
    @profile = current_user.build_buyer_profile
  end
  
  def create
    @profile = current_user.build_buyer_profile(profile_params)
    @profile.update_completeness!
    
    if @profile.save
      redirect_to buyer_profile_path, notice: 'Votre profil a été créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @profile = current_user.buyer_profile
  end
  
  def update
    if @profile.update(profile_params)
      @profile.update_completeness!
      redirect_to buyer_profile_path, notice: 'Votre profil a été mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def completeness
    @profile = current_user.buyer_profile
    @profile.update_completeness!
    
    render json: { 
      completeness_score: @profile.completeness_score,
      message: "Score de complétude: #{@profile.completeness_score}%"
    }
  end
  
  private
  
  def set_profile
    @profile = current_user.buyer_profile
    
    unless @profile
      redirect_to new_buyer_profile_path, alert: 'Veuillez créer votre profil pour continuer.'
    end
  end
  
  def require_buyer!
    unless current_user.buyer?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end
  
  def profile_params
    params.require(:buyer_profile).permit(
      :buyer_type,
      :formation,
      :experience,
      :skills,
      :investment_thesis,
      :target_revenue_min,
      :target_revenue_max,
      :target_employees_min,
      :target_employees_max,
      :target_financial_health,
      :target_horizon,
      :investment_capacity,
      :funding_sources,
      :linkedin_url,
      :profile_status,
      target_sectors: [],
      target_locations: [],
      target_transfer_types: [],
      target_customer_types: []
    )
  end
end
