module Payment
  class SubscriptionService
    class << self
      # Get current subscription for a user based on their role
      def current_subscription(user)
        return nil unless user
        
        user.subscriptions.active_subscriptions.order(created_at: :desc).first
      end
      
      # Check if user has an active subscription
      def has_active_subscription?(user)
        current_subscription(user)&.active? || false
      end
      
      # Get plan type for user's current subscription
      def current_plan_type(user)
        current_subscription(user)&.plan_type
      end
      
      # Check if user can access a specific feature
      def can_access_feature?(user, feature)
        subscription = current_subscription(user)
        return false unless subscription
        
        subscription.can_access_feature?(feature)
      end
      
      # Get feature limit for user
      def feature_limit(user, feature)
        subscription = current_subscription(user)
        return 0 unless subscription
        
        subscription.feature_limit(feature)
      end
      
      # Create a new subscription
      def create_subscription(user:, plan_type:, stripe_subscription_id: nil, stripe_customer_id: nil)
        # Get plan configuration
        role = user.role.to_sym
        plan_key = plan_type_to_key(plan_type)
        plan_config = SubscriptionPlans.plan_details(role, plan_key)
        
        return { success: false, error: 'Invalid plan type' } unless plan_config
        
        # Update user with Stripe customer ID if provided
        user.update(stripe_customer_id: stripe_customer_id) if stripe_customer_id && !user.stripe_customer_id
        
        # Cancel any existing active subscriptions
        cancel_existing_subscriptions(user)
        
        # Determine profile
        profile = get_profile_for_user(user)
        
        # Create subscription
        subscription = user.subscriptions.create(
          plan_type: plan_type,
          status: :active,
          amount: plan_config[:price_cents],
          stripe_subscription_id: stripe_subscription_id,
          profile: profile,
          period_start: Time.current,
          period_end: calculate_period_end(plan_config[:interval])
        )
        
        if subscription.persisted?
          { success: true, subscription: subscription }
        else
          { success: false, error: subscription.errors.full_messages.join(', ') }
        end
      end
      
      # Update subscription plan (upgrade/downgrade)
      def update_subscription_plan(subscription, new_plan_type)
        Rails.logger.info "=== SubscriptionService.update_subscription_plan ==="
        Rails.logger.info "Subscription: #{subscription.inspect}"
        Rails.logger.info "New plan type: #{new_plan_type}"
        
        return { success: false, error: 'Subscription not found' } unless subscription
        
        role = subscription.user.role.to_sym
        plan_key = plan_type_to_key(new_plan_type)
        
        Rails.logger.info "Role: #{role}, Plan key: #{plan_key}"
        
        plan_config = SubscriptionPlans.plan_details(role, plan_key)
        
        Rails.logger.info "Plan config: #{plan_config.inspect}"
        
        unless plan_config
          Rails.logger.error "Invalid plan type - no config found"
          return { success: false, error: 'Invalid plan type' }
        end
        
        Rails.logger.info "Updating subscription #{subscription.id} to plan_type: #{new_plan_type}, amount: #{plan_config[:price_cents]}"
        
        if subscription.update(
          plan_type: new_plan_type,
          amount: plan_config[:price_cents]
        )
          Rails.logger.info "Subscription updated successfully in database"
          { success: true, subscription: subscription.reload }
        else
          Rails.logger.error "Failed to update subscription: #{subscription.errors.full_messages.join(', ')}"
          { success: false, error: subscription.errors.full_messages.join(', ') }
        end
      end
      
      # Cancel subscription (with option for immediate or at period end)
      def cancel_subscription(subscription, immediate: false)
        return { success: false, error: 'Subscription not found' } unless subscription
        
        if immediate
          subscription.update(status: :cancelled, cancel_at_period_end: false)
        else
          subscription.update(cancel_at_period_end: true)
        end
        
        { success: true, subscription: subscription }
      end
      
      # Reactivate a cancelled subscription
      def reactivate_subscription(subscription)
        return { success: false, error: 'Subscription not found' } unless subscription
        return { success: false, error: 'Subscription is not cancelled' } unless subscription.cancelled?
        
        if subscription.update(status: :active, cancel_at_period_end: false)
          { success: true, subscription: subscription }
        else
          { success: false, error: subscription.errors.full_messages.join(', ') }
        end
      end
      
      # Renew subscription
      def renew_subscription(subscription)
        return { success: false, error: 'Subscription not found' } unless subscription
        
        plan_config = subscription.plan_config
        return { success: false, error: 'Plan configuration not found' } unless plan_config
        
        new_period_end = calculate_period_end(plan_config[:interval], from: subscription.period_end)
        
        if subscription.update(
          period_start: subscription.period_end,
          period_end: new_period_end,
          status: :active,
          cancel_at_period_end: false
        )
          { success: true, subscription: subscription }
        else
          { success: false, error: subscription.errors.full_messages.join(', ') }
        end
      end
      
      # Check if user has reached their feature limit
      def reached_limit?(user, feature)
        limit = feature_limit(user, feature)
        return false if limit == 999 # Unlimited
        return true if limit == 0 # No access
        
        # This would need to be customized based on the feature
        # For example, checking active deals count for 'active_deals'
        case feature.to_s
        when 'active_deals'
          user.deals.where(status: :active).count >= limit
        when 'reservations_per_month'
          user.deals.where('created_at >= ?', 1.month.ago).count >= limit
        else
          false
        end
      end
      
      # Activate subscription from Stripe webhook
      def activate_subscription(user:, stripe_subscription_id:, stripe_customer_id:, stripe_subscription:)
        Rails.logger.info "=" * 80
        Rails.logger.info "SubscriptionService.activate_subscription called"
        Rails.logger.info "User: ID=#{user.id}, Email=#{user.email}, Role=#{user.role}"
        Rails.logger.info "Stripe subscription ID: #{stripe_subscription_id}"
        Rails.logger.info "Stripe customer ID: #{stripe_customer_id}"
        
        # Extract plan type from Stripe price ID
        price_id = stripe_subscription.items.data.first.price.id
        Rails.logger.info "Price ID from Stripe: #{price_id}"
        
        plan_type = determine_plan_type_from_price_id(price_id)
        Rails.logger.info "Determined plan type: #{plan_type.inspect}"
        
        unless plan_type
          Rails.logger.error "❌ Could not determine plan type from price ID: #{price_id}"
          return { success: false, error: 'Could not determine plan type' }
        end
        
        # Get plan configuration to extract amount
        role = user.role.to_sym
        plan_key = plan_type_to_key(plan_type)
        Rails.logger.info "Role: #{role}, Plan key: #{plan_key}"
        
        plan_config = SubscriptionPlans.plan_details(role, plan_key)
        Rails.logger.info "Plan config: #{plan_config.inspect}"
        
        # Update user with Stripe customer ID
        if user.stripe_customer_id
          Rails.logger.info "User already has stripe_customer_id: #{user.stripe_customer_id}"
        else
          Rails.logger.info "Updating user with stripe_customer_id: #{stripe_customer_id}"
          user.update(stripe_customer_id: stripe_customer_id)
        end
        
        # Get user's profile
        profile = get_profile_for_user(user)
        Rails.logger.info "Profile: #{profile.class.name} ID=#{profile&.id}"
        
        # Create or update subscription
        subscription = user.subscriptions.find_or_initialize_by(stripe_subscription_id: stripe_subscription_id)
        is_new = subscription.new_record?
        Rails.logger.info "Subscription: #{is_new ? 'NEW RECORD' : "EXISTING ID=#{subscription.id}"}"
        
        # Map Stripe status to our enum values (Stripe uses 'canceled', we use 'cancelled')
        mapped_status = map_stripe_status_to_enum(stripe_subscription.status)
        Rails.logger.info "Status mapping: #{stripe_subscription.status} -> #{mapped_status}"
        
        Rails.logger.info "Assigning attributes:"
        Rails.logger.info "  - plan_type: #{plan_type}"
        Rails.logger.info "  - status: #{mapped_status}"
        Rails.logger.info "  - amount: #{plan_config[:price_cents]}"
        Rails.logger.info "  - profile: #{profile.class.name}"
        Rails.logger.info "  - period_start: #{Time.at(stripe_subscription.current_period_start)}"
        Rails.logger.info "  - period_end: #{Time.at(stripe_subscription.current_period_end)}"
        Rails.logger.info "  - cancel_at_period_end: #{stripe_subscription.cancel_at_period_end || false}"
        
        subscription.assign_attributes(
          plan_type: plan_type,
          status: mapped_status,
          amount: plan_config[:price_cents],
          profile: profile,
          period_start: Time.at(stripe_subscription.current_period_start),
          period_end: Time.at(stripe_subscription.current_period_end),
          cancel_at_period_end: stripe_subscription.cancel_at_period_end || false
        )
        
        Rails.logger.info "Attempting to save subscription..."
        if subscription.save
          Rails.logger.info "✓ Subscription saved successfully!"
          Rails.logger.info "  - Database ID: #{subscription.id}"
          Rails.logger.info "  - Plan type: #{subscription.plan_type}"
          Rails.logger.info "  - Status: #{subscription.status}"
          Rails.logger.info "  - User ID: #{user.id}"
          { success: true, subscription: subscription }
        else
          Rails.logger.error "❌ Failed to save subscription!"
          Rails.logger.error "Validation errors: #{subscription.errors.full_messages.join(', ')}"
          Rails.logger.error "Error details: #{subscription.errors.to_hash.inspect}"
          { success: false, error: subscription.errors.full_messages.join(', ') }
        end
      end
      
      # Get subscription status summary for user
      def subscription_summary(user)
        subscription = current_subscription(user)
        
        if subscription.nil?
          return {
            has_subscription: false,
            plan_name: 'Free',
            status: 'No active subscription',
            features: []
          }
        end
        
        {
          has_subscription: true,
          subscription: subscription,
          plan_name: subscription.plan_name,
          plan_type: subscription.plan_type,
          status: subscription.renewal_status_text,
          amount: subscription.plan_price_display,
          interval: subscription.plan_interval,
          features: subscription.plan_features,
          limits: subscription.plan_limits,
          days_until_renewal: subscription.days_until_renewal,
          renewal_date: subscription.renewal_date,
          needs_attention: subscription.needs_attention?,
          will_renew: subscription.will_renew?
        }
      end
      
      private
      
      def cancel_existing_subscriptions(user)
        user.subscriptions.active_subscriptions.each do |sub|
          sub.update(status: :cancelled, cancel_at_period_end: false)
        end
      end
      
      def get_profile_for_user(user)
        case user.role.to_sym
        when :buyer
          user.buyer_profile || user.create_buyer_profile!
        when :seller
          user.seller_profile || user.create_seller_profile!
        when :partner
          user.partner_profile || user.create_partner_profile!
        else
          nil
        end
      end
      
      def calculate_period_end(interval, from: Time.current)
        case interval.to_s
        when 'month'
          from + 1.month
        when 'year'
          from + 1.year
        else
          from + 1.month
        end
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
      
      def determine_plan_type_from_price_id(price_id)
        # Map Stripe Price IDs to plan types
        price_mapping = {
          ENV['STRIPE_BUYER_STARTER_PRICE_ID'] => 'buyer_starter',
          ENV['STRIPE_BUYER_STANDARD_PRICE_ID'] => 'buyer_standard',
          ENV['STRIPE_BUYER_PREMIUM_PRICE_ID'] => 'buyer_premium',
          ENV['STRIPE_BUYER_CLUB_PRICE_ID'] => 'buyer_club',
          ENV['STRIPE_SELLER_PREMIUM_PRICE_ID'] => 'seller_premium',
          ENV['STRIPE_PARTNER_ANNUAL_PRICE_ID'] => 'partner_directory'
        }
        
        price_mapping[price_id]
      end
      
      # Map Stripe status values to our database enum values
      # Stripe uses 'canceled' (one L), we use 'cancelled' (two L's)
      def map_stripe_status_to_enum(stripe_status)
        case stripe_status
        when 'canceled'
          'cancelled'
        when 'active', 'trialing'
          'active'
        when 'past_due', 'unpaid'
          'failed'
        when 'incomplete', 'incomplete_expired'
          'pending'
        else
          stripe_status
        end
      end
    end
  end
end
