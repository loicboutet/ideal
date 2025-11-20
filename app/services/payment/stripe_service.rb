module Payment
  class StripeService
    class << self
      # Create or retrieve Stripe customer for user
      def get_or_create_customer(user)
        return { success: false, error: 'User required' } unless user
        
        # Return existing customer if already created
        if user.stripe_customer_id.present?
          begin
            customer = Stripe::Customer.retrieve(user.stripe_customer_id)
            return { success: true, customer: customer }
          rescue Stripe::StripeError => e
            Rails.logger.error("Stripe customer retrieval failed: #{e.message}")
            # Continue to create new customer if retrieval fails
          end
        end
        
        # Create new Stripe customer
        begin
          customer = Stripe::Customer.create(
            email: user.email,
            name: user.full_name || user.email,
            metadata: {
              user_id: user.id,
              role: user.role
            }
          )
          
          # Save customer ID to user
          user.update(stripe_customer_id: customer.id)
          
          { success: true, customer: customer }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe customer creation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Create Stripe Checkout session for subscription
      def create_subscription_checkout_session(user:, plan_type:, success_url:, cancel_url:)
        # Get or create customer
        customer_result = get_or_create_customer(user)
        return customer_result unless customer_result[:success]
        
        customer = customer_result[:customer]
        
        # Get plan configuration
        role = user.role.to_sym
        plan_key = plan_type_to_key(plan_type)
        plan_config = SubscriptionPlans.plan_details(role, plan_key)
        
        return { success: false, error: 'Invalid plan type' } unless plan_config
        return { success: false, error: 'No Stripe price ID configured' } unless plan_config[:stripe_price_id]
        
        begin
          # Create checkout session
          session = Stripe::Checkout::Session.create(
            customer: customer.id,
            mode: 'subscription',
            line_items: [{
              price: plan_config[:stripe_price_id],
              quantity: 1
            }],
            success_url: success_url,
            cancel_url: cancel_url,
            metadata: {
              user_id: user.id,
              plan_type: plan_type,
              role: user.role
            },
            subscription_data: {
              metadata: {
                user_id: user.id,
                plan_type: plan_type
              }
            }
          )
          
          { success: true, session: session, checkout_url: session.url }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe checkout session creation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Create Stripe Checkout session for one-time credit purchase
      def create_credit_purchase_checkout_session(user:, credit_pack:, success_url:, cancel_url:)
        # Get or create customer
        customer_result = get_or_create_customer(user)
        return customer_result unless customer_result[:success]
        
        customer = customer_result[:customer]
        
        return { success: false, error: 'Invalid credit pack' } unless credit_pack&.active?
        
        begin
          # Create checkout session for one-time payment
          session = Stripe::Checkout::Session.create(
            customer: customer.id,
            mode: 'payment',
            line_items: [{
              price_data: {
                currency: 'eur',
                unit_amount: credit_pack.price_cents,
                product_data: {
                  name: credit_pack.name,
                  description: credit_pack.description || "#{credit_pack.credits_amount} credits"
                }
              },
              quantity: 1
            }],
            success_url: success_url,
            cancel_url: cancel_url,
            metadata: {
              user_id: user.id,
              credit_pack_id: credit_pack.id,
              credits_amount: credit_pack.credits_amount,
              purchase_type: 'credit_pack'
            }
          )
          
          { success: true, session: session, checkout_url: session.url }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe credit purchase session creation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Update subscription in Stripe
      def update_stripe_subscription(subscription, new_plan_type)
        return { success: false, error: 'No Stripe subscription ID' } unless subscription.stripe_subscription_id
        
        role = subscription.user.role.to_sym
        plan_key = plan_type_to_key(new_plan_type)
        plan_config = SubscriptionPlans.plan_details(role, plan_key)
        
        return { success: false, error: 'Invalid plan type' } unless plan_config
        return { success: false, error: 'No Stripe price ID configured' } unless plan_config[:stripe_price_id]
        
        begin
          stripe_subscription = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
          
          # Update subscription to new price
          updated_subscription = Stripe::Subscription.update(
            stripe_subscription.id,
            items: [{
              id: stripe_subscription.items.data[0].id,
              price: plan_config[:stripe_price_id]
            }],
            proration_behavior: 'create_prorations'
          )
          
          { success: true, subscription: updated_subscription }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe subscription update failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Cancel subscription in Stripe
      def cancel_stripe_subscription(subscription, immediate: false)
        return { success: false, error: 'No Stripe subscription ID' } unless subscription.stripe_subscription_id
        
        begin
          if immediate
            # Cancel immediately
            canceled_subscription = Stripe::Subscription.cancel(subscription.stripe_subscription_id)
          else
            # Cancel at period end
            canceled_subscription = Stripe::Subscription.update(
              subscription.stripe_subscription_id,
              cancel_at_period_end: true
            )
          end
          
          { success: true, subscription: canceled_subscription }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe subscription cancellation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Reactivate a cancelled subscription in Stripe
      def reactivate_stripe_subscription(subscription)
        return { success: false, error: 'No Stripe subscription ID' } unless subscription.stripe_subscription_id
        
        begin
          reactivated_subscription = Stripe::Subscription.update(
            subscription.stripe_subscription_id,
            cancel_at_period_end: false
          )
          
          { success: true, subscription: reactivated_subscription }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe subscription reactivation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Retrieve subscription from Stripe
      def retrieve_stripe_subscription(stripe_subscription_id)
        return { success: false, error: 'Subscription ID required' } unless stripe_subscription_id
        
        begin
          subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
          { success: true, subscription: subscription }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe subscription retrieval failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Create customer portal session for managing subscriptions
      def create_customer_portal_session(user, return_url:)
        return { success: false, error: 'User has no Stripe customer ID' } unless user.stripe_customer_id
        
        begin
          session = Stripe::BillingPortal::Session.create(
            customer: user.stripe_customer_id,
            return_url: return_url
          )
          
          { success: true, session: session, portal_url: session.url }
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe portal session creation failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Retrieve payment intent
      def retrieve_payment_intent(payment_intent_id)
        return { success: false, error: 'Payment intent ID required' } unless payment_intent_id
        
        begin
          payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
          { success: true, payment_intent: payment_intent }
        rescue Stripe::StripeError => e
          Rails.logger.error("Payment intent retrieval failed: #{e.message}")
          { success: false, error: e.message }
        end
      end
      
      # Handle successful checkout session (called from webhook)
      def handle_checkout_completed(session)
        return { success: false, error: 'Invalid session' } unless session
        
        user_id = session.metadata&.user_id
        return { success: false, error: 'No user ID in metadata' } unless user_id
        
        user = User.find_by(id: user_id)
        return { success: false, error: 'User not found' } unless user
        
        case session.mode
        when 'subscription'
          handle_subscription_checkout(session, user)
        when 'payment'
          handle_payment_checkout(session, user)
        else
          { success: false, error: 'Unknown session mode' }
        end
      end
      
      private
      
      def handle_subscription_checkout(session, user)
        plan_type = session.metadata.plan_type
        stripe_subscription_id = session.subscription
        
        # Create subscription record
        result = Payment::SubscriptionService.create_subscription(
          user: user,
          plan_type: plan_type,
          stripe_subscription_id: stripe_subscription_id,
          stripe_customer_id: session.customer
        )
        
        if result[:success]
          # Log successful payment transaction
          log_subscription_payment(user, result[:subscription], session)
          { success: true, subscription: result[:subscription] }
        else
          { success: false, error: result[:error] }
        end
      end
      
      def handle_payment_checkout(session, user)
        purchase_type = session.metadata.purchase_type
        
        case purchase_type
        when 'credit_pack'
          handle_credit_pack_purchase(session, user)
        else
          { success: false, error: 'Unknown purchase type' }
        end
      end
      
      def handle_credit_pack_purchase(session, user)
        credit_pack_id = session.metadata.credit_pack_id
        credits_amount = session.metadata.credits_amount.to_i
        
        credit_pack = CreditPack.find_by(id: credit_pack_id)
        return { success: false, error: 'Credit pack not found' } unless credit_pack
        
        # Add credits to user
        user.increment!(:credits_balance, credits_amount)
        
        # Log transaction
        PaymentTransaction.create!(
          user: user,
          amount: session.amount_total,
          currency: session.currency.upcase,
          status: :succeeded,
          stripe_payment_intent_id: session.payment_intent,
          transaction_type: :credit_purchase,
          description: "Purchase of #{credits_amount} credits",
          metadata: { credit_pack_id: credit_pack_id, session_id: session.id }.to_json
        )
        
        { success: true, credits_added: credits_amount }
      end
      
      def log_subscription_payment(user, subscription, session)
        PaymentTransaction.create!(
          user: user,
          amount: session.amount_total || subscription.amount,
          currency: 'EUR',
          status: :succeeded,
          stripe_payment_intent_id: session.payment_intent,
          transaction_type: :subscription_payment,
          description: "Subscription: #{subscription.plan_name}",
          metadata: {
            subscription_id: subscription.id,
            plan_type: subscription.plan_type,
            session_id: session.id
          }.to_json
        )
      end
      
      def plan_type_to_key(plan_type)
        case plan_type.to_s
        when 'buyer_starter' then :starter
        when 'buyer_standard' then :standard
        when 'buyer_premium' then :premium
        when 'buyer_club' then :club
        when 'seller_premium' then :premium
        when 'partner_directory' then :annual
        else
          plan_type.to_sym
        end
      end
    end
  end
end
