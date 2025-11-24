class ListingNotificationMailer < ApplicationMailer
  default from: 'notifications@ideal-reprise.fr'

  def listing_approved(listing)
    @listing = listing
    @seller = listing.seller_profile.user
    
    mail(
      to: @seller.email,
      subject: "✅ Votre annonce \"#{@listing.title}\" a été approuvée"
    )
  end

  def listing_rejected(listing)
    @listing = listing
    @seller = listing.seller_profile.user
    
    mail(
      to: @seller.email,
      subject: "❌ Votre annonce \"#{@listing.title}\" a été rejetée"
    )
  end
end
