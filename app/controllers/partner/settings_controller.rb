class Partner::SettingsController < ApplicationController
  layout 'partner'
  
  before_action :authenticate_user!
  before_action :require_partner!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(settings_params)
      redirect_to partner_settings_path, notice: "Paramètres mis à jour avec succès."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def require_partner!
    unless current_user.partner?
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end

  def settings_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :notify_contact_requests,
      :notify_subscription_renewal
    )
  end
end
