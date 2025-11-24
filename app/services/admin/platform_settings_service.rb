module Admin
  class PlatformSettingsService
    TIMER_MIN_DAYS = 7
    TIMER_MAX_DAYS = 60

    def initialize
      @errors = []
    end

    # Fetch all settings grouped by category
    def fetch_all
      {
        pricing: fetch_pricing_settings,
        timers: fetch_timer_settings,
        texts: fetch_text_settings
      }
    end

    # Update settings with validation
    def update_settings(params, updated_by_user)
      @errors = []
      
      ActiveRecord::Base.transaction do
        params.each do |key, value|
          setting = PlatformSetting.find_or_initialize_by(setting_key: key)
          
          # Validate value based on setting type
          unless validate_setting(key, value)
            raise ActiveRecord::Rollback
          end
          
          setting.setting_value = value
          setting.updated_by = updated_by_user
          setting.save!
        end
      end
      
      @errors.empty?
    end

    def errors
      @errors
    end

    private

    def fetch_pricing_settings
      {
        buyer_plan_starter_monthly: get_setting('buyer_plan_starter_monthly', '89'),
        buyer_plan_standard_monthly: get_setting('buyer_plan_standard_monthly', '199'),
        buyer_plan_premium_monthly: get_setting('buyer_plan_premium_monthly', '249'),
        buyer_plan_club_annual: get_setting('buyer_plan_club_annual', '1200'),
        credits_pack_small_price: get_setting('credits_pack_small_price', '50'),
        credits_pack_small_credits: get_setting('credits_pack_small_credits', '10'),
        credits_pack_medium_price: get_setting('credits_pack_medium_price', '100'),
        credits_pack_medium_credits: get_setting('credits_pack_medium_credits', '25'),
        credits_pack_large_price: get_setting('credits_pack_large_price', '180'),
        credits_pack_large_credits: get_setting('credits_pack_large_credits', '50')
      }
    end

    def fetch_timer_settings
      {
        timer_to_contact: get_setting('timer_to_contact', '7'),
        timer_info_analysis_alignment: get_setting('timer_info_analysis_alignment', '33'),
        timer_negotiation: get_setting('timer_negotiation', '20')
      }
    end

    def fetch_text_settings
      {
        text_welcome_message: get_setting('text_welcome_message', 'Bienvenue sur Idéal Reprise ! Nous sommes ravis de vous accompagner dans votre projet.'),
        text_validation_message: get_setting('text_validation_message', 'Votre annonce a été validée et est maintenant visible par les repreneurs.'),
        text_offer_starter: get_setting('text_offer_starter', 'Accès de base aux annonces'),
        text_offer_standard: get_setting('text_offer_standard', 'Accès complet + réservations illimitées'),
        text_offer_premium: get_setting('text_offer_premium', 'Tous les avantages + badge vérifié'),
        text_offer_club: get_setting('text_offer_club', 'Accès VIP + coaching personnalisé')
      }
    end

    def get_setting(key, default = nil)
      PlatformSetting.get(key) || default
    end

    def validate_setting(key, value)
      case key
      when /^timer_/
        validate_timer(key, value)
      when /_price$/, /^buyer_plan_/
        validate_price(key, value)
      when /_credits$/
        validate_credits(key, value)
      when /^text_/
        validate_text(key, value)
      else
        true
      end
    end

    def validate_timer(key, value)
      days = value.to_i
      
      if days < TIMER_MIN_DAYS || days > TIMER_MAX_DAYS
        @errors << "#{key}: La durée doit être entre #{TIMER_MIN_DAYS} et #{TIMER_MAX_DAYS} jours"
        return false
      end
      
      true
    end

    def validate_price(key, value)
      price = value.to_f
      
      if price <= 0
        @errors << "#{key}: Le prix doit être supérieur à 0"
        return false
      end
      
      true
    end

    def validate_credits(key, value)
      credits = value.to_i
      
      if credits <= 0
        @errors << "#{key}: Le nombre de crédits doit être supérieur à 0"
        return false
      end
      
      true
    end

    def validate_text(key, value)
      if value.blank?
        @errors << "#{key}: Le texte ne peut pas être vide"
        return false
      end
      
      if value.length > 1000
        @errors << "#{key}: Le texte ne peut pas dépasser 1000 caractères"
        return false
      end
      
      true
    end
  end
end
