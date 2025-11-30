module Payment
  class CreditService
    class InsufficientCreditsError < StandardError; end
    class InvalidAmountError < StandardError; end
    
    # Add credits to a user's account
    # @param user [User] The user receiving credits
    # @param amount [Integer] Number of credits to add (must be positive)
    # @param transaction_type [Symbol] Type of transaction (e.g., :purchase, :deal_release, :enrichment_validated)
    # @param source [ActiveRecord::Base] Optional source object (Deal, Enrichment, etc.)
    # @param description [String] Optional description
    # @return [Boolean] true if successful, false otherwise
    def self.add_credits(user, amount, transaction_type, source: nil, description: nil)
      validate_amount!(amount, positive: true)
      
      ActiveRecord::Base.transaction do
        profile = get_profile(user)
        
        # Update credits balance
        new_balance = profile.credits + amount
        profile.update!(credits: new_balance)
        
        # Log transaction for sellers (buyers don't have credit_transactions table yet)
        if user.seller? && user.seller_profile
          log_seller_transaction(user.seller_profile, amount, transaction_type, new_balance, source, description)
        end
        
        # Log general payment transaction
        log_payment_transaction(user, amount, transaction_type, source, description)
        
        # Send notification
        send_credit_notification(user, amount, transaction_type, description)
        
        true
      end
    rescue => e
      Rails.logger.error "Failed to add credits for user #{user.id}: #{e.message}"
      false
    end
    
    # Deduct credits from a user's account
    # @param user [User] The user spending credits
    # @param amount [Integer] Number of credits to deduct (must be positive)
    # @param transaction_type [Symbol] Type of transaction (e.g., :push_to_buyer, :partner_contact)
    # @param source [ActiveRecord::Base] Optional source object
    # @param description [String] Optional description
    # @return [Boolean] true if successful
    # @raise [InsufficientCreditsError] if user doesn't have enough credits
    def self.deduct_credits(user, amount, transaction_type, source: nil, description: nil)
      validate_amount!(amount, positive: true)
      
      profile = get_profile(user)
      
      # Check balance
      unless has_sufficient_credits?(user, amount)
        raise InsufficientCreditsError, "Insufficient credits. Required: #{amount}, Available: #{profile.credits}"
      end
      
      ActiveRecord::Base.transaction do
        # Update credits balance
        new_balance = profile.credits - amount
        profile.update!(credits: new_balance)
        
        # Log transaction for sellers
        if user.seller? && user.seller_profile
          log_seller_transaction(user.seller_profile, -amount, transaction_type, new_balance, source, description)
        end
        
        # Log general payment transaction
        log_payment_transaction(user, -amount, transaction_type, source, description)
        
        true
      end
    rescue InsufficientCreditsError => e
      Rails.logger.warn "Insufficient credits for user #{user.id}: #{e.message}"
      raise
    rescue => e
      Rails.logger.error "Failed to deduct credits for user #{user.id}: #{e.message}"
      false
    end
    
    # Check if user has sufficient credits
    # @param user [User] The user to check
    # @param amount [Integer] Number of credits required
    # @return [Boolean] true if user has enough credits
    def self.has_sufficient_credits?(user, amount)
      profile = get_profile(user)
      profile.credits >= amount
    end
    
    # Get user's current credit balance
    # @param user [User] The user
    # @return [Integer] Current credit balance
    def self.get_balance(user)
      profile = get_profile(user)
      profile.credits
    end
    
    # Get transaction history for a user
    # @param user [User] The user
    # @param limit [Integer] Maximum number of transactions to return
    # @return [ActiveRecord::Relation] Transaction history
    def self.transaction_history(user, limit: 50)
      if user.seller? && user.seller_profile
        user.seller_profile.credit_transactions.recent.limit(limit)
      else
        # For buyers, return payment transactions related to credits
        PaymentTransaction.where(user: user)
                         .where("transaction_type LIKE ?", "%credit%")
                         .order(created_at: :desc)
                         .limit(limit)
      end
    end
    
    # Award credits for deal release
    # @param deal [Deal] The released deal
    # @return [Boolean] true if successful, false if no credits awarded (e.g., only favorited)
    def self.award_deal_release_credits(deal)
      # Only award credits if the deal was actually reserved (moved beyond "favorited" stage)
      # Deals that were only favorited should not receive credits when released
      unless deal_was_reserved?(deal)
        Rails.logger.info "No credits awarded for deal #{deal.id}: deal was only favorited, never reserved"
        return false
      end
      
      buyer_user = deal.buyer_profile.user
      seller_user = deal.listing.seller_profile.user
      
      # Calculate credits based on enrichments
      base_credits = 1
      enrichment_credits = deal.listing.enrichments
                               .where(buyer_profile_id: deal.buyer_profile_id, validated: true)
                               .count
      
      total_credits = base_credits + enrichment_credits
      
      # Award credits to buyer
      add_credits(
        buyer_user,
        total_credits,
        :deal_release,
        source: deal,
        description: "Dossier libéré - #{deal.listing.title}"
      )
      
      # Award +1 credit to seller when buyer releases deal voluntarily
      if deal.release_reason.present?
        add_credits(
          seller_user,
          1,
          :deal_release,
          source: deal,
          description: "Dossier libéré par #{buyer_user.full_name}"
        )
      end
      
      true
    rescue => e
      Rails.logger.error "Failed to award deal release credits: #{e.message}"
      false
    end
    
    # Award credits for validated enrichment
    # @param enrichment [Enrichment] The validated enrichment
    # @return [Boolean] true if successful
    def self.award_enrichment_credits(enrichment)
      return false unless enrichment.validated?
      
      buyer_user = enrichment.buyer_profile.user
      
      add_credits(
        buyer_user,
        1,
        :enrichment_validated,
        source: enrichment,
        description: "Document validé - #{enrichment.document_category}"
      )
    end
    
    # Deduct credits for listing push
    # @param listing_push [ListingPush] The listing push
    # @return [Boolean] true if successful
    def self.deduct_push_credits(listing_push)
      seller_user = listing_push.seller_profile.user
      
      deduct_credits(
        seller_user,
        1,
        :push_to_buyer,
        source: listing_push,
        description: "Annonce poussée à #{listing_push.buyer_profile.user.full_name}"
      )
    end
    
    # Deduct credits for partner contact (after 6 months)
    # @param user [User] The user contacting partner
    # @param partner [PartnerProfile] The partner being contacted
    # @return [Boolean] true if successful
    def self.deduct_partner_contact_credits(user, partner)
      # Check if user has been active for 6 months
      return true if user.created_at > 6.months.ago
      
      deduct_credits(
        user,
        5,
        :partner_contact,
        source: partner,
        description: "Contact partenaire - #{partner.user.company_name || partner.user.full_name}"
      )
    end
    
    # Process credit pack purchase
    # @param user [User] The user purchasing credits
    # @param credit_pack [CreditPack] The credit pack being purchased
    # @param stripe_payment_intent_id [String] Stripe payment intent ID
    # @return [Boolean] true if successful
    def self.process_credit_purchase(user, credit_pack, stripe_payment_intent_id: nil)
      add_credits(
        user,
        credit_pack.credits_amount,
        :purchase,
        source: credit_pack,
        description: "Achat #{credit_pack.name} - #{credit_pack.price_formatted}"
      )
      
      # Create payment transaction record
      PaymentTransaction.create!(
        user: user,
        amount: credit_pack.price_in_euros,
        currency: 'EUR',
        status: 'succeeded',
        stripe_payment_intent_id: stripe_payment_intent_id,
        transaction_type: 'credit_purchase',
        description: "Achat de #{credit_pack.credits_amount} crédits",
        metadata: { credit_pack_id: credit_pack.id }.to_json
      )
      
      true
    rescue => e
      Rails.logger.error "Failed to process credit purchase: #{e.message}"
      false
    end
    
    # Check if a deal was actually reserved (moved beyond favorited stage)
    # @param deal [Deal] The deal to check
    # @return [Boolean] true if the deal was reserved at some point
    def self.deal_was_reserved?(deal)
      # A deal is considered "reserved" if:
      # 1. It has the reserved flag set to true, OR
      # 2. Its current status is beyond "favorited" (meaning it progressed in the pipeline), OR
      # 3. It has history events showing it moved beyond favorited
      
      return true if deal.reserved?
      
      # Check if current status is beyond favorited
      # The enum values are: favorited: 0, to_contact: 1, etc.
      # Anything > 0 means it was worked on (but also check it's not just released/abandoned)
      current_status_value = Deal.statuses[deal.status]
      return true if current_status_value > 0 && current_status_value < Deal.statuses[:released]
      
      # Check history for any status beyond favorited
      deal.deal_history_events
          .where(event_type: :status_change)
          .where.not(to_status: [:favorited, :released, :abandoned])
          .exists?
    end
    
    private
    
    # Get the appropriate profile for a user
    def self.get_profile(user)
      case user.role
      when 'buyer'
        user.buyer_profile || raise("Buyer profile not found for user #{user.id}")
      when 'seller'
        user.seller_profile || raise("Seller profile not found for user #{user.id}")
      when 'partner'
        # Partners don't use credits in current implementation
        raise "Partners don't have credit system"
      else
        raise "Invalid user role: #{user.role}"
      end
    end
    
    # Validate credit amount
    def self.validate_amount!(amount, positive: false)
      raise InvalidAmountError, "Amount must be a number" unless amount.is_a?(Numeric)
      raise InvalidAmountError, "Amount must be positive" if positive && amount <= 0
      raise InvalidAmountError, "Amount cannot be zero" if amount == 0
    end
    
    # Log transaction for seller
    def self.log_seller_transaction(seller_profile, amount, transaction_type, balance_after, source, description)
      seller_profile.credit_transactions.create!(
        amount: amount,
        transaction_type: transaction_type,
        source: source,
        description: description,
        balance_after: balance_after
      )
    end
    
    # Log general payment transaction
    def self.log_payment_transaction(user, amount, transaction_type, source, description)
      # Create a general activity log
      Activity.create!(
        user: user,
        trackable: source,
        action_type: :payment_processed,
        metadata: {
          amount: amount,
          transaction_type: transaction_type,
          description: description
        }.to_json
      )
    end
    
    # Send notification for credit transaction
    def self.send_credit_notification(user, amount, transaction_type, description)
      return unless amount > 0 # Only notify on credits earned
      
      Notification.create!(
        user: user,
        notification_type: :credit_earned,
        title: "Crédits gagnés",
        message: "Vous avez gagné #{amount} crédit(s) : #{description || transaction_type}",
        link_url: user.buyer? ? Rails.application.routes.url_helpers.buyer_credits_path : Rails.application.routes.url_helpers.seller_credits_path
      )
    rescue => e
      Rails.logger.error "Failed to send credit notification: #{e.message}"
      # Don't fail the transaction if notification fails
    end
  end
end
