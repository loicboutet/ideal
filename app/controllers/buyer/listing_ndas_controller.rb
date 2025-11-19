# frozen_string_literal: true

module Buyer
  class ListingNdasController < ApplicationController
    layout 'buyer'
    
    before_action :authenticate_user!
    before_action :ensure_buyer!
    before_action :set_buyer_profile
    before_action :set_listing
    before_action :ensure_platform_nda_signed

    def create
      # Check if already signed for this listing
      if current_user.nda_signatures.exists?(signature_type: :listing_specific, listing_id: @listing.id)
        redirect_to buyer_listing_path(@listing), alert: "Vous avez déjà signé l'accord de confidentialité pour cette annonce."
        return
      end

      # Verify acceptance
      unless params[:accepted_terms] == '1'
        redirect_to buyer_listing_path(@listing), alert: "Vous devez accepter les termes de l'accord de confidentialité."
        return
      end

      # Create listing-specific NDA signature
      @nda_signature = current_user.nda_signatures.create!(
        signature_type: :listing_specific,
        listing_id: @listing.id,
        signed_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        accepted_terms: true
      )

      redirect_to buyer_listing_path(@listing), notice: "✅ Accord de confidentialité signé. Vous pouvez maintenant accéder aux informations confidentielles."
    end

    private

    def set_buyer_profile
      @buyer_profile = current_user.buyer_profile
      
      unless @buyer_profile
        redirect_to root_path, alert: "Vous devez avoir un profil repreneur pour accéder à cette page."
      end
    end

    def set_listing
      @listing = Listing.find(params[:listing_id])
    end

    def ensure_buyer!
      unless current_user&.buyer?
        redirect_to root_path, alert: "Accès non autorisé."
      end
    end

    def ensure_platform_nda_signed
      unless current_user.nda_signatures.exists?(signature_type: :platform_wide)
        session[:return_to_after_nda] = buyer_listing_path(@listing)
        redirect_to buyer_nda_path, alert: "Vous devez d'abord signer l'accord de confidentialité plateforme."
      end
    end
  end
end
