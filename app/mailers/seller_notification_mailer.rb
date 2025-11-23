class SellerNotificationMailer < ApplicationMailer
  default from: 'notifications@ideal-reprise.fr'

  def document_validation_request(enrichment)
    @enrichment = enrichment
    @listing = enrichment.listing
    @seller = @listing.seller_profile.user
    @buyer = enrichment.buyer_profile.user
    @listing_url = seller_listing_url(@listing)
    
    mail(
      to: @seller.email,
      subject: "📄 Nouveau document à valider pour votre annonce \"#{@listing.title}\""
    )
  end
end
