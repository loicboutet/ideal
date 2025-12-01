# frozen_string_literal: true

module Mockups
  module Partner
    class ContactsController < MockupsController
      layout 'mockup_partner'

      # GET /mockups/partner/contacts
      # Liste des personnes qui ont contacté le partenaire via l'annuaire
      def index
        # Mock contacts - sellers and buyers who contacted this partner
      end

      # GET /mockups/partner/contacts/:id
      # Détail d'un contact
      def show
        @contact_id = params[:id]
      end
    end
  end
end
