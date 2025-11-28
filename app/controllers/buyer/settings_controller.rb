class Buyer::SettingsController < ApplicationController
  layout 'buyer'
  
  before_action :authenticate_user!
  before_action :authorize_buyer!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(settings_params)
      redirect_to buyer_settings_path, notice: "Paramètres mis à jour avec succès."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def authorize_buyer!
    unless current_user&.buyer? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Buyer privileges required.'
    end
  end

  def settings_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :notify_new_listings,
      :notify_messages,
      :notify_timer_alerts
    )
  end
end
