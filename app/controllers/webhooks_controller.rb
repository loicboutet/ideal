class WebhooksController < ApplicationController
  # Skip CSRF verification for Stripe webhooks
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, if: :devise_controller?

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
    else
      Rails.logger.info "Unhandled event type: #{event['type']}"
    end

    head :ok
  end

  private

  def handle_checkout_session_completed(session)
    Rails.logger.info "Processing checkout.session.completed for session: #{session['id']}"
    
    # Get user from client_reference_id (user_id stored during checkout)
    user = User.find_by(id: session['client_reference_id'])
    
    unless user
      Rails.logger.error "User not found for session: #{session['id']}"
      return
    end

    # Get subscription details from Stripe
    stripe_subscription_id = session['subscription']
    
    if stripe_subscription_id
      # Subscription payment
      stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
      
      # Activate subscription in database
      Payment::SubscriptionService.activate_subscription(
        user: user,
        stripe_subscription_id: stripe_subscription_id,
        stripe_customer_id: session['customer'],
        stripe_subscription: stripe_subscription
      )
      
      Rails.logger.info "Subscription activated for user #{user.id}"
    else
      # One-time payment (credit pack purchase)
      # This will be handled in Phase 4
      Rails.logger.info "One-time payment completed for user #{user.id}"
    end

    # Create payment transaction record
    PaymentTransaction.create!(
      user: user,
      stripe_payment_intent_id: session['payment_intent'],
      amount: session['amount_total'] / 100.0, # Convert from cents
      currency: session['currency'],
      status: 'succeeded',
      transaction_type: stripe_subscription_id ? 'subscription' : 'credit_pack',
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

    # Update subscription status
    user_subscription = user.subscription
    if user_subscription
      user_subscription.update!(
        status: subscription['status'],
        current_period_start: Time.at(subscription['current_period_start']),
        current_period_end: Time.at(subscription['current_period_end'])
      )
    end
  rescue => e
    Rails.logger.error "Error processing subscription.created: #{e.message}"
  end

  def handle_subscription_updated(subscription)
    Rails.logger.info "Processing customer.subscription.updated: #{subscription['id']}"
    
    user = User.find_by(stripe_customer_id: subscription['customer'])
    return unless user

    user_subscription = user.subscription
    return unless user_subscription

    # Update subscription details
    user_subscription.update!(
      status: subscription['status'],
      current_period_start: Time.at(subscription['current_period_start']),
      current_period_end: Time.at(subscription['current_period_end']),
      cancel_at_period_end: subscription['cancel_at_period_end']
    )

    # Handle plan changes
    if subscription['items'] && subscription['items']['data'].any?
      price_id = subscription['items']['data'].first['price']['id']
      if price_id != user_subscription.stripe_price_id
        user_subscription.update!(stripe_price_id: price_id)
        Rails.logger.info "Subscription plan changed for user #{user.id}"
      end
    end
  rescue => e
    Rails.logger.error "Error processing subscription.updated: #{e.message}"
  end

  def handle_subscription_deleted(subscription)
    Rails.logger.info "Processing customer.subscription.deleted: #{subscription['id']}"
    
    user = User.find_by(stripe_customer_id: subscription['customer'])
    return unless user

    user_subscription = user.subscription
    return unless user_subscription

    # Mark subscription as canceled
    user_subscription.update!(
      status: 'canceled',
      ends_at: Time.at(subscription['ended_at'] || Time.now.to_i)
    )

    Rails.logger.info "Subscription canceled for user #{user.id}"
  rescue => e
    Rails.logger.error "Error processing subscription.deleted: #{e.message}"
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
      transaction_type: 'subscription_renewal',
      metadata: {
        invoice_id: invoice['id'],
        subscription_id: invoice['subscription']
      }
    )

    # Ensure subscription is active
    if user.subscription
      user.subscription.update!(status: 'active')
    end
  rescue => e
    Rails.logger.error "Error processing invoice.payment_succeeded: #{e.message}"
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
      transaction_type: 'subscription_renewal',
      metadata: {
        invoice_id: invoice['id'],
        subscription_id: invoice['subscription'],
        failure_message: invoice['last_finalization_error']&.dig('message')
      }
    )

    # Update subscription status to past_due
    if user.subscription
      user.subscription.update!(status: 'past_due')
    end

    # TODO: Send notification email to user
    Rails.logger.warn "Payment failed for user #{user.id}"
  rescue => e
    Rails.logger.error "Error processing invoice.payment_failed: #{e.message}"
  end
end
