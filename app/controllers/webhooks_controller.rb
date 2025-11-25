class WebhooksController < ApplicationController
  # Skip CSRF verification for Stripe webhooks
  skip_forgery_protection

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    # Verify webhook signature
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook Error: Invalid payload - #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook Error: Invalid signature - #{e.message}"
      return head :bad_request
    end

    # Handle the event
    case event['type']
    when 'checkout.session.completed'
      handle_checkout_session_completed(event['data']['object'])
    when 'customer.subscription.created'
      handle_subscription_created(event['data']['object'])
    when 'customer.subscription.updated'
      handle_subscription_updated(event['data']['object'])
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event['data']['object'])
    when 'invoice.payment_succeeded'
      handle_invoice_payment_succeeded(event['data']['object'])
    when 'invoice.payment_failed'
      handle_invoice_payment_failed(event['data']['object'])
    when 'invoice.updated'
      handle_invoice_updated(event['data']['object'])
    when 'invoice.paid'
      handle_invoice_paid(event['data']['object'])
    when 'invoice_payment.paid'
      handle_invoice_payment_paid(event['data']['object'])
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end

    head :ok
  end

  private

  def handle_checkout_session_completed(session)
    Rails.logger.info "=" * 80
    Rails.logger.info "Processing checkout.session.completed for session: #{session['id']}"
    Rails.logger.info "Session data: customer=#{session['customer']}, subscription=#{session['subscription']}"
    Rails.logger.info "Session metadata: #{session['metadata'].inspect}"
    Rails.logger.info "Client reference ID: #{session['client_reference_id']}"
    
    # Get user from client_reference_id (user_id stored during checkout)
    user = User.find_by(id: session['client_reference_id'])
    
    unless user
      Rails.logger.error "❌ User not found for client_reference_id: #{session['client_reference_id']}"
      Rails.logger.error "Session: #{session['id']}"
      return
    end
    
    Rails.logger.info "✓ Found user: ID=#{user.id}, Email=#{user.email}, Role=#{user.role}"

    # Get subscription details from Stripe
    stripe_subscription_id = session['subscription']
    
    Rails.logger.info "Stripe subscription ID from session: #{stripe_subscription_id}"
    
    # Only log if this is a subscription-related checkout
    if stripe_subscription_id
      Rails.logger.info "→ This is a subscription checkout"
      
      # Subscription payment
      Rails.logger.info "Retrieving subscription from Stripe: #{stripe_subscription_id}"
      stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
      
      Rails.logger.info "Stripe subscription retrieved: status=#{stripe_subscription.status}, items=#{stripe_subscription.items.data.first.price.id}"
      
      # Activate subscription in database
      Rails.logger.info "Calling SubscriptionService.activate_subscription..."
      result = Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: stripe_subscription_id,
        stripe_customer_id: session['customer'],
        stripe_subscription: stripe_subscription
      )
      
      if result[:success]
        Rails.logger.info "✓ Subscription activated successfully for user #{user.id}"
        Rails.logger.info "Subscription ID: #{result[:subscription].id}, Plan: #{result[:subscription].plan_type}, Status: #{result[:subscription].status}"
      else
        Rails.logger.error "❌ Failed to activate subscription: #{result[:error]}"
      end
    else
      # One-time payment (credit pack purchase)
      metadata = session['metadata']
      if metadata && metadata['transaction_type'] == 'credit_purchase'
        credit_pack_id = metadata['credit_pack_id']
        credit_pack = CreditPack.find_by(id: credit_pack_id)
        
        if credit_pack
          # Process credit purchase using the credit service
          Payment::CreditService.process_credit_purchase(
            user,
            credit_pack,
            stripe_payment_intent_id: session['payment_intent']
          )
          Rails.logger.info "Credit purchase processed for user #{user.id}: #{credit_pack.credits_amount} credits"
        else
          Rails.logger.error "Credit pack not found for ID: #{credit_pack_id}"
        end
      else
        Rails.logger.info "One-time payment completed for user #{user.id}"
      end
    end

    # Create payment transaction record
    PaymentTransaction.create!(
      user: user,
      stripe_payment_intent_id: session['payment_intent'],
      amount: session['amount_total'] / 100.0, # Convert from cents
      currency: session['currency'],
      status: 'succeeded',
      transaction_type: stripe_subscription_id ? 'subscription_payment' : 'credit_purchase',
      metadata: {
        session_id: session['id'],
        subscription_id: stripe_subscription_id
      }
    )
  rescue => e
    Rails.logger.error "Error processing checkout.session.completed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_subscription_created(subscription)
    Rails.logger.info "Processing customer.subscription.created: #{subscription['id']}"
    
    user = User.find_by(stripe_customer_id: subscription['customer'])
    return unless user

    # Check if subscription already exists
    existing_subscription = user.subscriptions.find_by(stripe_subscription_id: subscription['id'])
    
    if existing_subscription
      Rails.logger.info "Subscription #{subscription['id']} already exists with status: #{existing_subscription.status}"
      
      # Map the new status from Stripe
      new_mapped_status = map_stripe_status_to_enum(subscription['status'])
      
      # Check if we should update the status (prevent downgrades)
      if should_update_status?(existing_subscription.status, new_mapped_status)
        Rails.logger.info "Updating subscription status from #{existing_subscription.status} to #{new_mapped_status}"
        Payment::SubscriptionService.activate_subscription(
          user: user,
          stripe_subscription_id: subscription['id'],
          stripe_customer_id: subscription['customer'],
          stripe_subscription: subscription
        )
      else
        Rails.logger.info "Skipping status update - would downgrade from #{existing_subscription.status} to #{new_mapped_status}"
        # Still update period dates and other fields, just not status
        existing_subscription.update(
          period_start: Time.at(subscription['current_period_start']),
          period_end: Time.at(subscription['current_period_end']),
          cancel_at_period_end: subscription['cancel_at_period_end'] || false
        )
      end
    else
      # New subscription, create it
      Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: subscription['id'],
        stripe_customer_id: subscription['customer'],
        stripe_subscription: subscription
      )
    end
  rescue => e
    Rails.logger.error "Error processing subscription.created: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_subscription_updated(subscription)
    Rails.logger.info "Processing customer.subscription.updated: #{subscription['id']}"
    Rails.logger.info "Stripe data: status=#{subscription['status']}, cancel_at_period_end=#{subscription['cancel_at_period_end']}"
    
    user = User.find_by(stripe_customer_id: subscription['customer'])
    unless user
      Rails.logger.error "User not found for customer: #{subscription['customer']}"
      return
    end


    # Find or create subscription
    user_subscription = user.subscriptions.find_by(stripe_subscription_id: subscription['id'])
    
    unless user_subscription
      Rails.logger.info "Subscription not found, creating new one..."
      # Subscription doesn't exist, create it using the service
      result = Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: subscription['id'],
        stripe_customer_id: subscription['customer'],
        stripe_subscription: subscription
      )
      return unless result[:success]
      user_subscription = result[:subscription]
    end

    Rails.logger.info "Found subscription ID #{user_subscription.id} - current values: status=#{user_subscription.status}, cancel_at_period_end=#{user_subscription.cancel_at_period_end}"

    # Map Stripe status to our enum values
    mapped_status = map_stripe_status_to_enum(subscription['status'])
    
    Rails.logger.info "Mapped status: #{subscription['status']} -> #{mapped_status}"

    # Update subscription details
    update_result = user_subscription.update(
      status: mapped_status,
      period_start: Time.at(subscription['current_period_start']),
      period_end: Time.at(subscription['current_period_end']),
      cancel_at_period_end: subscription['cancel_at_period_end']
    )
    
    if update_result
      user_subscription.reload
      Rails.logger.info "Subscription #{subscription['id']} SAVED successfully"
      Rails.logger.info "New values in DB: status=#{user_subscription.status}, cancel_at_period_end=#{user_subscription.cancel_at_period_end}"
    else
      Rails.logger.error "Subscription #{subscription['id']} FAILED to save!"
      Rails.logger.error "Validation errors: #{user_subscription.errors.full_messages.join(', ')}"
    end
  rescue => e
    Rails.logger.error "Error processing subscription.updated: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_subscription_deleted(subscription)
    Rails.logger.info "Processing customer.subscription.deleted: #{subscription['id']}"
    
    user = User.find_by(stripe_customer_id: subscription['customer'])
    return unless user


    user_subscription = user.subscriptions.find_by(stripe_subscription_id: subscription['id'])
    return unless user_subscription

    # Mark subscription as cancelled (using our enum spelling)
    user_subscription.update!(
      status: 'cancelled',
      ends_at: Time.at(subscription['ended_at'] || Time.now.to_i)
    )

    Rails.logger.info "Subscription cancelled for user #{user.id}"
  rescue => e
    Rails.logger.error "Error processing subscription.deleted: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_invoice_payment_succeeded(invoice)
    Rails.logger.info "Processing invoice.payment_succeeded: #{invoice['id']}"
    
    user = User.find_by(stripe_customer_id: invoice['customer'])
    return unless user


    # Record successful payment
    PaymentTransaction.create!(
      user: user,
      stripe_payment_intent_id: invoice['payment_intent'],
      amount: invoice['amount_paid'] / 100.0,
      currency: invoice['currency'],
      status: 'succeeded',
      transaction_type: 'subscription_payment',
      metadata: {
        invoice_id: invoice['id'],
        subscription_id: invoice['subscription']
      }
    )

    # Find or create subscription
    user_subscription = user.subscriptions.find_by(stripe_subscription_id: invoice['subscription'])
    
    unless user_subscription
      # Subscription doesn't exist, retrieve from Stripe and create it
      stripe_subscription = Stripe::Subscription.retrieve(invoice['subscription'])
      result = Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: invoice['subscription'],
        stripe_customer_id: invoice['customer'],
        stripe_subscription: stripe_subscription
      )
      user_subscription = result[:subscription] if result[:success]
    end

    # Ensure subscription is active
    if user_subscription
      user_subscription.update!(status: 'active')
    end
  rescue => e
    Rails.logger.error "Error processing invoice.payment_succeeded: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_invoice_payment_failed(invoice)
    Rails.logger.info "Processing invoice.payment_failed: #{invoice['id']}"
    
    user = User.find_by(stripe_customer_id: invoice['customer'])
    return unless user

    # Record failed payment
    PaymentTransaction.create!(
      user: user,
      stripe_payment_intent_id: invoice['payment_intent'],
      amount: invoice['amount_due'] / 100.0,
      currency: invoice['currency'],
      status: 'failed',
      transaction_type: 'subscription_payment',
      metadata: {
        invoice_id: invoice['id'],
        subscription_id: invoice['subscription'],
        failure_message: invoice['last_finalization_error']&.dig('message')
      }
    )

    # Update subscription status to past_due
    user_subscription = user.subscriptions.find_by(stripe_subscription_id: invoice['subscription'])
    if user_subscription
      user_subscription.update!(status: 'past_due')
    end

    # TODO: Send notification email to user
    Rails.logger.warn "Payment failed for user #{user.id}"
  rescue => e
    Rails.logger.error "Error processing invoice.payment_failed: #{e.message}"
  end

  def handle_invoice_updated(invoice)
    Rails.logger.info "Processing invoice.updated: #{invoice['id']}"
    
    # This event is informational - we handle payment status in other events
    # Just log it for now, no action needed
  rescue => e
    Rails.logger.error "Error processing invoice.updated: #{e.message}"
  end

  def handle_invoice_paid(invoice)
    Rails.logger.info "Processing invoice.paid: #{invoice['id']}"
    
    # Same as invoice.payment_succeeded - just an alias
    handle_invoice_payment_succeeded(invoice)
  rescue => e
    Rails.logger.error "Error processing invoice.paid: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def handle_invoice_payment_paid(invoice_payment)
    Rails.logger.info "Processing invoice_payment.paid: #{invoice_payment['id']}"
    
    # Retrieve the full invoice to get customer information
    invoice_id = invoice_payment['invoice']
    invoice = Stripe::Invoice.retrieve(invoice_id)
    
    user = User.find_by(stripe_customer_id: invoice['customer'])
    return unless user

    # Get payment intent ID from the payment object
    payment_intent_id = invoice_payment['payment']['payment_intent']

    # Record successful payment
    PaymentTransaction.create!(
      user: user,
      stripe_payment_intent_id: payment_intent_id,
      amount: invoice_payment['amount_paid'] / 100.0,
      currency: invoice_payment['currency'],
      status: 'succeeded',
      transaction_type: 'subscription_payment',
      metadata: {
        invoice_payment_id: invoice_payment['id'],
        invoice_id: invoice_id,
        subscription_id: invoice['subscription']
      }
    )

    # Find or create subscription
    user_subscription = user.subscriptions.find_by(stripe_subscription_id: invoice['subscription'])
    
    unless user_subscription
      # Subscription doesn't exist, retrieve from Stripe and create it
      stripe_subscription = Stripe::Subscription.retrieve(invoice['subscription'])
      result = Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: invoice['subscription'],
        stripe_customer_id: invoice['customer'],
        stripe_subscription: stripe_subscription
      )
      user_subscription = result[:subscription] if result[:success]
    end

    # Ensure subscription is active
    if user_subscription
      user_subscription.update!(status: 'active')
    end

    Rails.logger.info "Invoice payment recorded for user #{user.id}"
  rescue => e
    Rails.logger.error "Error processing invoice_payment.paid: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
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
  
  # Determine status hierarchy to prevent downgrades
  # Higher values = better status
  def status_hierarchy
    {
      'pending' => 0,
      'failed' => 1,
      'expired' => 2,
      'cancelled' => 3,
      'active' => 4
    }
  end
  
  # Check if we should update the status (only allow upgrades or lateral moves)
  def should_update_status?(current_status, new_status)
    current_rank = status_hierarchy[current_status.to_s] || 0
    new_rank = status_hierarchy[new_status.to_s] || 0
    
    # Allow update if new status is equal or better
    new_rank >= current_rank
  end
end
