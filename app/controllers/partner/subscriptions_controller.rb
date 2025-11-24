class Partner::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_partner_role
  before_action :set_subscription, only: [:show, :destroy, :reactivate]
  
  # GET /partner/subscription
  def show
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    @summary = Payment::SubscriptionService.subscription_summary(current_user)
    @annual_plan = SubscriptionPlans.plan_details(:partner, :annual)
    
    # Check if subscription needs renewal soon
    if @subscription&.active?
      @days_until_renewal = @subscription.days_until_renewal
      @needs_renewal_soon = @days_until_renewal && @days_until_renewal < 30
    end
  end
  
  # GET /partner/subscription/new
  # Display annual subscription information and purchase page
  def new
    @current_subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    if @current_subscription&.active? && !@current_subscription.cancelled?
      redirect_to partner_subscription_path, notice: 'You already have an active directory subscription'
      return
    end
    
    @annual_plan = SubscriptionPlans.plan_details(:partner, :annual)
    @free_plan = SubscriptionPlans.plan_details(:partner, :free)
  end
  
  # POST /partner/subscription
  # Create Stripe Checkout session for annual directory subscription
  def create
    plan_type = 'partner_directory'
    
    # Create Stripe Checkout session
    result = Payment::StripeService.create_subscription_checkout_session(
      user: current_user,
      plan_type: plan_type,
      success_url: partner_subscription_url(session_id: '{CHECKOUT_SESSION_ID}'),
      cancel_url: new_partner_subscription_url
    )
    
    if result[:success]
      # Redirect to Stripe Checkout
      redirect_to result[:checkout_url], allow_other_host: true
    else
      redirect_to new_partner_subscription_path, alert: "Unable to start checkout: #{result[:error]}"
    end
  end
  
  # DELETE /partner/subscription
  # Cancel annual subscription (always immediate)
  def destroy
    # Always cancel immediately
    immediate = true
    
    # Cancel in Stripe first
    stripe_result = Payment::StripeService.cancel_stripe_subscription(@subscription, immediate: immediate)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.cancel_subscription(@subscription, immediate: immediate)
      
      if result[:success]
        redirect_to partner_subscription_path, notice: 'Your directory subscription has been cancelled immediately.'
      else
        redirect_to partner_subscription_path, alert: "Unable to cancel subscription: #{result[:error]}"
      end
    else
      redirect_to partner_subscription_path, alert: "Unable to cancel subscription: #{stripe_result[:error]}"
    end
  end
  
  # POST /partner/subscription/reactivate
  # Reactivate a cancelled subscription
  def reactivate
    unless @subscription.cancelled?
      redirect_to partner_subscription_path, alert: 'This subscription is not cancelled'
      return
    end
    
    # Reactivate in Stripe first
    stripe_result = Payment::StripeService.reactivate_stripe_subscription(@subscription)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.reactivate_subscription(@subscription)
      
      if result[:success]
        redirect_to partner_subscription_path, notice: 'Your directory subscription has been reactivated successfully!'
      else
        redirect_to partner_subscription_path, alert: "Unable to reactivate subscription: #{result[:error]}"
      end
    else
      redirect_to partner_subscription_path, alert: "Unable to reactivate subscription: #{stripe_result[:error]}"
    end
  end
  
  # GET /partner/subscription/renew
  # Show renewal page
  def renew_form
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    @annual_plan = SubscriptionPlans.plan_details(:partner, :annual)
    
    # If no active subscription or subscription is cancelled, redirect to new
    unless @subscription&.active?
      redirect_to new_partner_subscription_path
      return
    end
    
    # If subscription will auto-renew, no need for manual renewal
    if @subscription.will_renew?
      redirect_to partner_subscription_path, notice: 'Your subscription will renew automatically'
      return
    end
  end
  
  # POST /partner/subscription/renew
  # Process renewal (reactivate cancelled subscription or create new one)
  def renew
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    if @subscription&.cancelled?
      # Reactivate cancelled subscription
      redirect_to reactivate_partner_subscription_path, method: :post
    else
      # No active subscription, create new one
      redirect_to new_partner_subscription_path
    end
  end
  
  # GET /partner/subscription/cancel_confirm
  # Show cancellation confirmation page
  def cancel_confirm
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to partner_subscription_path, alert: 'No active subscription found'
    end
  end
  
  private
  
  def set_subscription
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to new_partner_subscription_path, alert: 'No active subscription found'
    end
  end
  
  def ensure_partner_role
    unless current_user.partner?
      redirect_to root_path, alert: 'Access denied'
    end
  end
end
