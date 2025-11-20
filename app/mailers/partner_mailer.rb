# frozen_string_literal: true

class PartnerMailer < ApplicationMailer
  default from: 'notifications@ideal-reprise.fr'

  def profile_approved(partner_profile)
    @partner_profile = partner_profile
    @user = partner_profile.user
    
    mail(
      to: @user.email,
      subject: '✅ Votre profil partenaire a été approuvé - Idéal Reprise'
    )
  end

  def profile_rejected(partner_profile, reason = nil)
    @partner_profile = partner_profile
    @user = partner_profile.user
    @reason = reason
    
    mail(
      to: @user.email,
      subject: '❌ Votre profil partenaire nécessite des modifications - Idéal Reprise'
    )
  end

  def new_contact(partner_profile, contact)
    @partner_profile = partner_profile
    @user = partner_profile.user
    @contact = contact
    @contact_user = contact.user
    
    mail(
      to: @user.email,
      subject: '📬 Nouveau contact depuis l\'annuaire partenaire - Idéal Reprise'
    )
  end
end
