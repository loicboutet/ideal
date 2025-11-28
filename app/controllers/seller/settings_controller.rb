class Seller::SettingsController < Seller::BaseController
  before_action :authenticate_user!
  before_action :ensure_seller!

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

  def settings_params
    params.require(:user).permit(
      :notify_new_contacts,
      :notify_seller_messages,
      :receive_signed_ndas
    )
  end
end
