# frozen_string_literal: true

module Buyer
  class NdasController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile

    def show
      # Check if already signed
      @platform_nda_signed = current_user.nda_signatures.exists?(signature_type: :platform_wide)
      
      if @platform_nda_signed
        redirect_to buyer_root_path, notice: "Vous avez déjà signé l'accord de confidentialité plateforme."
      end
    end

    def create
      # Check if already signed
      if current_user.nda_signatures.exists?(signature_type: :platform_wide)
        redirect_to buyer_root_path, alert: "Vous avez déjà signé l'accord de confidentialité plateforme."
        return
      end

      # Verify acceptance
      unless params[:accepted_terms] == '1'
        redirect_to buyer_nda_path, alert: "Vous devez accepter les termes de l'accord de confidentialité."
        return
      end

      # Create NDA signature
      @nda_signature = current_user.nda_signatures.create!(
        signature_type: :platform_wide,
        signed_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        accepted_terms: true
      )

      # Redirect to original destination or dashboard
      redirect_url = session.delete(:return_to_after_nda) || buyer_root_path
      redirect_to redirect_url, notice: "✅ Accord de confidentialité signé avec succès."
    end

    private

    def set_buyer_profile
      @buyer_profile = current_user.buyer_profile
      
      unless @buyer_profile
        redirect_to root_path, alert: "Vous devez avoir un profil repreneur pour accéder à cette page."
      end
    end

    def ensure_buyer!
      unless current_user&.buyer?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end
  end
end
