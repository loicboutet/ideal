class Seller::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role
  before_action :set_subscription, only: [:show, :destroy, :reactivate]
  
  # GET /seller/subscription
  def show
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    @summary = Payment::SubscriptionService.subscription_summary(current_user)
    @premium_plan = SubscriptionPlans.plan_details(:seller, :premium)
    
    # Calculate partner directory access status
    if @subscription&.active?
      @partner_access_expires_at = calculate_partner_access_expiry(@subscription)
      @partner_access_is_free = @partner_access_expires_at > Time.current
    end
  end
  
  # GET /seller/subscription/new
  # Display premium package information and purchase page
  def new
    @current_subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    if @current_subscription&.active?
      redirect_to seller_subscription_path, notice: 'You already have an active premium subscription'
      return
    end
    
    @premium_plan = SubscriptionPlans.plan_details(:seller, :premium)
    @free_plan = SubscriptionPlans.plan_details(:seller, :free)
  end
  
  # POST /seller/subscription
  # Create subscription with payment method (JavaScript flow)
  def create
    plan_type = 'seller_premium'
    payment_method_id = params[:payment_method_id]
    
    if payment_method_id.present?
      # JavaScript flow - create subscription with payment method
      result = Payment::StripeService.create_subscription_with_payment_method(
        user: current_user,
        plan_type: plan_type,
        payment_method_id: payment_method_id
      )
      
      respond_to do |format|
        format.json do
          if result[:success]
            render json: { 
              success: true,
              subscription: result[:subscription],
              requires_action: result[:requires_action],
              client_secret: result[:client_secret]
            }
          else
            Rails.logger.error "Subscription creation failed: #{result[:error]}"
            render json: { success: false, error: result[:error] }, status: :unprocessable_entity
          end
        end
        format.html do
          if result[:success]
            redirect_to seller_subscription_path, notice: 'Premium subscription activated successfully!'
          else
            redirect_to new_seller_subscription_path, alert: "Unable to create subscription: #{result[:error]}"
          end
        end
      end
    else
      # Fallback to Stripe Checkout session (redirect flow)
      result = Payment::StripeService.create_subscription_checkout_session(
        user: current_user,
        plan_type: plan_type,
        success_url: seller_subscription_url(session_id: '{CHECKOUT_SESSION_ID}'),
        cancel_url: new_seller_subscription_url
      )
      
      if result[:success]
        # Redirect to Stripe Checkout
        redirect_to result[:checkout_url], allow_other_host: true
      else
        redirect_to new_seller_subscription_path, alert: "Unable to start checkout: #{result[:error]}"
      end
    end
  end
  
  # DELETE /seller/subscription
  # Cancel premium subscription (always immediate)
  def destroy
    # Always cancel immediately
    immediate = true
    
    # Cancel in Stripe first
    stripe_result = Payment::StripeService.cancel_stripe_subscription(@subscription, immediate: immediate)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.cancel_subscription(@subscription, immediate: immediate)
      
      if result[:success]
        redirect_to seller_subscription_path, notice: 'Your premium subscription has been cancelled immediately.'
      else
        redirect_to seller_subscription_path, alert: "Unable to cancel subscription: #{result[:error]}"
      end
    else
      redirect_to seller_subscription_path, alert: "Unable to cancel subscription: #{stripe_result[:error]}"
    end
  end
  
  # POST /seller/subscription/reactivate
  # Reactivate a cancelled subscription
  def reactivate
    unless @subscription.cancelled?
      redirect_to seller_subscription_path, alert: 'This subscription is not cancelled'
      return
    end
    
    # Reactivate in Stripe first
    stripe_result = Payment::StripeService.reactivate_stripe_subscription(@subscription)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.reactivate_subscription(@subscription)
      
      if result[:success]
        redirect_to seller_subscription_path, notice: 'Your premium subscription has been reactivated successfully!'
      else
        redirect_to seller_subscription_path, alert: "Unable to reactivate subscription: #{result[:error]}"
      end
    else
      redirect_to seller_subscription_path, alert: "Unable to reactivate subscription: #{stripe_result[:error]}"
    end
  end
  
  # GET /seller/subscription/cancel_confirm
  # Show cancellation confirmation page
  def cancel_confirm
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to seller_subscription_path, alert: 'No active subscription found'
    end
  end
  
  # GET /seller/subscription/upgrade
  # Show premium package purchase page (redirect to new)
  def upgrade
    redirect_to new_seller_subscription_path
  end
  
  private
  
  def set_subscription
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to new_seller_subscription_path, alert: 'No active subscription found'
    end
  end
  
  def ensure_seller_role
    unless current_user.seller?
      redirect_to root_path, alert: 'Access denied'
    end
  end
  
  def calculate_partner_access_expiry(subscription)
    # Partner directory access is free for first 6 months
    free_months = subscription.plan_limits[:partner_directory_free_months] || 6
    subscription.period_start + free_months.months
  end
end
