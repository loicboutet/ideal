class Buyer::NdasController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role
  
  def show
    # Check if user has already signed platform-wide NDA
    @already_signed = current_user.nda_signatures.platform_wide.exists?
    
    if @already_signed
      redirect_to buyer_root_path, notice: "Vous avez déjà signé l'accord de confidentialité."
    end
  end
  
  def create
    # Check if already signed
    if current_user.nda_signatures.platform_wide.exists?
      redirect_to buyer_root_path, alert: "Vous avez déjà signé l'accord de confidentialité."
      return
    end
    
    # Create NDA signature
    @nda_signature = current_user.nda_signatures.build(
      signature_type: :platform_wide,
      signed_at: Time.current,
      ip_address: request.remote_ip
    )
    
    if @nda_signature.save
      # TODO: Send email confirmation (future enhancement)
      # NdaMailer.platform_nda_signed(current_user).deliver_later
      
      redirect_to buyer_root_path, notice: "Accord de confidentialité signé avec succès."
    else
      flash.now[:alert] = "Une erreur s'est produite lors de la signature."
      render :show
    end
  end
  
  private
  
  def ensure_buyer_role
    unless current_user.buyer?
      redirect_to root_path, alert: "Accès réservé aux acheteurs."
    end
  end
end
