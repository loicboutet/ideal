class BuyerNotificationMailer < ApplicationMailer
  default from: 'notifications@ideal-reprise.fr'

  def new_deal_available(buyer_profile, listing)
    @buyer_profile = buyer_profile
    @buyer = buyer_profile.user
    @listing = listing
    @listing_url = buyer_listing_url(listing)
    
    mail(
      to: @buyer.email,
      subject: "🎯 Nouvelle opportunité correspondant à vos critères"
    )
  end

  def favorited_deal_available(buyer_profile, listing)
    @buyer_profile = buyer_profile
    @buyer = buyer_profile.user
    @listing = listing
    @listing_url = buyer_listing_url(listing)
    
    mail(
      to: @buyer.email,
      subject: "⭐ Une annonce que vous avez mise en favoris est à nouveau disponible"
    )
  end

  def reservation_expiring(deal)
    @deal = deal
    @buyer_profile = deal.buyer_profile
    @buyer = @buyer_profile.user
    @listing = deal.listing
    @deal_url = buyer_deals_url
    @time_remaining = time_remaining_text(deal)
    
    mail(
      to: @buyer.email,
      subject: "⏰ Votre réservation expire bientôt - #{@listing.title}"
    )
  end

  private

  def time_remaining_text(deal)
    return "bientôt" unless deal.reserved_until
    
    time_left = deal.reserved_until - Time.current
    return "bientôt" if time_left <= 0
    
    hours = (time_left / 3600).to_i
    days = (time_left / 86400).to_i
    
    if days > 0
      "#{days} jour#{'s' if days > 1}"
    elsif hours > 0
      "#{hours} heure#{'s' if hours > 1}"
    else
      "moins d'une heure"
    end
  end
end
