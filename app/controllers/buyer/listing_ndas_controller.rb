class Buyer::ListingNdasController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role
  before_action :set_listing
  
  def create
    # Check if user has already signed this listing's NDA
    if current_user.nda_signatures.listing_specific.exists?(listing: @listing)
      redirect_to buyer_listing_path(@listing), alert: "Vous avez déjà signé l'accord de confidentialité pour cette annonce."
      return
    end
    
    # Create listing-specific NDA signature
    @nda_signature = current_user.nda_signatures.build(
      signature_type: :listing_specific,
      listing: @listing,
      signed_at: Time.current,
      ip_address: request.remote_ip
    )
    
    if @nda_signature.save
      # TODO: Send email confirmation to buyer (future enhancement)
      # NdaMailer.listing_nda_signed(current_user, @listing).deliver_later
      
      # TODO: Optionally notify seller (future enhancement)
      # NdaMailer.notify_seller_of_nda(@listing.seller, @listing, current_user).deliver_later
      
      redirect_to buyer_listing_path(@listing), notice: "Accord de confidentialité signé. Vous pouvez maintenant accéder aux informations confidentielles."
    else
      redirect_to buyer_listing_path(@listing), alert: "Une erreur s'est produite lors de la signature."
    end
  end
  
  private
  
  def set_listing
    @listing = Listing.find(params[:listing_id])
  end
  
  def ensure_buyer_role
    unless current_user.buyer?
      redirect_to root_path, alert: "Accès réservé aux acheteurs."
    end
  end
end
