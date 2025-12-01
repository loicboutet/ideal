# frozen_string_literal: true

class Partner::ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_partner!

  # GET /partner/contacts
  # Liste des personnes qui ont contacté le partenaire via l'annuaire
  def index
    # TODO: Implement real contact fetching from database
    # @contacts = current_user.partner_profile.contacts.order(created_at: :desc)
  end

  # GET /partner/contacts/:id
  # Détail d'un contact spécifique
  def show
    @contact_id = params[:id]
    # TODO: Implement real contact fetching
    # @contact = current_user.partner_profile.contacts.find(params[:id])
  end

  private

  def authorize_partner!
    unless current_user&.partner? && current_user&.active?
      redirect_to root_path, alert: 'Accès refusé. Privilèges partenaire requis.'
    end
  end
end
