class Seller::SettingsController < ApplicationController
  layout 'seller'
  
  before_action :authenticate_user!
  before_action :authorize_seller!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(settings_params)
      redirect_to seller_settings_path, notice: "Paramètres mis à jour avec succès."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def authorize_seller!
    unless current_user&.seller_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de cédant requis.'
    end
  end

  def settings_params
    params.require(:user).permit(
      :notify_new_contacts,
      :notify_seller_messages,
      :receive_signed_ndas
    )
  end
end
