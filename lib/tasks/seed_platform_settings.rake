namespace :db do
  namespace :seed do
    desc "Seed platform settings with default values"
    task platform_settings: :environment do
      puts "Seeding platform settings..."

      settings = [
        # Buyer Subscription Pricing
        { key: 'buyer_plan_starter_monthly', value: '89', type: 'decimal', description: 'Prix mensuel abonnement Starter pour repreneurs (€)' },
        { key: 'buyer_plan_standard_monthly', value: '199', type: 'decimal', description: 'Prix mensuel abonnement Standard pour repreneurs (€)' },
        { key: 'buyer_plan_premium_monthly', value: '249', type: 'decimal', description: 'Prix mensuel abonnement Premium pour repreneurs (€)' },
        { key: 'buyer_plan_club_annual', value: '1200', type: 'decimal', description: 'Prix annuel abonnement Club pour repreneurs (€)' },

        # Credit Packs Pricing
        { key: 'credits_pack_small_price', value: '50', type: 'decimal', description: 'Prix pack Small - 10 crédits (€)' },
        { key: 'credits_pack_small_credits', value: '10', type: 'integer', description: 'Nombre de crédits pack Small' },
        { key: 'credits_pack_medium_price', value: '100', type: 'decimal', description: 'Prix pack Medium - 25 crédits (€)' },
        { key: 'credits_pack_medium_credits', value: '25', type: 'integer', description: 'Nombre de crédits pack Medium' },
        { key: 'credits_pack_large_price', value: '180', type: 'decimal', description: 'Prix pack Large - 50 crédits (€)' },
        { key: 'credits_pack_large_credits', value: '50', type: 'integer', description: 'Nombre de crédits pack Large' },

        # Pipeline Timer Settings (in days)
        { key: 'timer_to_contact', value: '7', type: 'integer', description: 'Durée timer "À contacter" (jours, min 7, max 60)' },
        { key: 'timer_info_analysis_alignment', value: '33', type: 'integer', description: 'Durée timer "Échange infos + Analyse + Alignement" total (jours, min 7, max 60)' },
        { key: 'timer_negotiation', value: '20', type: 'integer', description: 'Durée timer "Négociation" (jours, min 7, max 60)' },
        
        # LOI stage has no timer - requires seller validation
        # Audits, Financing, Deal Signed stages have no timers

        # Platform Text Settings
        { key: 'text_welcome_message', value: 'Bienvenue sur Idéal Reprise ! Nous sommes ravis de vous accompagner dans votre projet.', type: 'string', description: 'Message de bienvenue pour nouveaux utilisateurs' },
        { key: 'text_validation_message', value: 'Votre annonce a été validée et est maintenant visible par les repreneurs.', type: 'string', description: 'Message lors de la validation d\'une annonce' },
        { key: 'text_offer_starter', value: 'Accès de base aux annonces', type: 'string', description: 'Description offre Starter' },
        { key: 'text_offer_standard', value: 'Accès complet + réservations illimitées', type: 'string', description: 'Description offre Standard' },
        { key: 'text_offer_premium', value: 'Tous les avantages + badge vérifié', type: 'string', description: 'Description offre Premium' },
        { key: 'text_offer_club', value: 'Accès VIP + coaching personnalisé', type: 'string', description: 'Description offre Club' },
      ]

      settings.each do |setting_data|
        setting = PlatformSetting.find_or_initialize_by(setting_key: setting_data[:key])
        setting.setting_value = setting_data[:value]
        setting.setting_type = setting_data[:type]
        setting.description = setting_data[:description]
        
        if setting.new_record?
          setting.save!
          puts "  ✓ Created setting: #{setting_data[:key]}"
        else
          setting.save!
          puts "  ✓ Updated setting: #{setting_data[:key]}"
        end
      end

      puts "Platform settings seeded successfully!"
      puts "Total settings: #{PlatformSetting.count}"
    end
  end
end
