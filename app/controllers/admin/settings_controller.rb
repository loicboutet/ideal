module Admin
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def show
      @settings = Admin::PlatformSettingsService.new.fetch_all
    end

    def update
      service = Admin::PlatformSettingsService.new
      
      if service.update_settings(setting_params, current_user)
        # Log the activity
        Activity.create(
          user: current_user,
          action_type: :platform_settings_updated,
          metadata: { updated_settings: setting_params.keys },
          ip_address: request.remote_ip
        )
        
        redirect_to admin_settings_path, notice: 'Les paramètres de la plateforme ont été mis à jour avec succès.'
      else
        @settings = service.fetch_all
        flash.now[:alert] = 'Erreur lors de la mise à jour des paramètres. Veuillez vérifier les valeurs saisies.'
        render :show
      end
    end

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: 'Accès non autorisé.'
      end
    end

    def setting_params
      params.require(:settings).permit(
        # Buyer subscription pricing
        :buyer_plan_starter_monthly,
        :buyer_plan_standard_monthly,
        :buyer_plan_premium_monthly,
        :buyer_plan_club_annual,
        
        # Credit packs pricing
        :credits_pack_small_price,
        :credits_pack_small_credits,
        :credits_pack_medium_price,
        :credits_pack_medium_credits,
        :credits_pack_large_price,
        :credits_pack_large_credits,
        
        # Timer settings
        :timer_to_contact,
        :timer_info_analysis_alignment,
        :timer_negotiation,
        
        # Text settings
        :text_welcome_message,
        :text_validation_message,
        :text_offer_starter,
        :text_offer_standard,
        :text_offer_premium,
        :text_offer_club
      )
    end
  end
end
