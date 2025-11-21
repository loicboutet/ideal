class Buyer::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_buyer_role
  before_action :set_subscription, only: [:show, :edit, :update, :destroy, :reactivate]
  
  # GET /buyer/subscription
  def show
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    @summary = Payment::SubscriptionService.subscription_summary(current_user)
    @all_plans = SubscriptionPlans.all_buyer_plans
  end
  
  # GET /buyer/subscription/new
  # Display plan selection/comparison page
  def new
    @current_subscription = Payment::SubscriptionService.current_subscription(current_user)
    @all_plans = SubscriptionPlans.all_buyer_plans
    @current_plan_type = @current_subscription&.plan_type
  end
  
  # POST /buyer/subscription
  # Create Stripe Checkout session and redirect to Stripe
  def create
    plan_type = params[:plan_type]
    
    unless valid_buyer_plan?(plan_type)
      redirect_to new_buyer_subscription_path, alert: 'Invalid plan selected'
      return
    end
    
    # Create Stripe Checkout session
    result = Payment::StripeService.create_subscription_checkout_session(
      user: current_user,
      plan_type: plan_type,
      success_url: "#{buyer_subscription_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: new_buyer_subscription_url
    )
    
    if result[:success]
      # Redirect to Stripe Checkout
      redirect_to result[:checkout_url], allow_other_host: true
    else
      redirect_to new_buyer_subscription_path, alert: "Unable to start checkout: #{result[:error]}"
    end
  end
  
  # GET /buyer/subscription/edit
  # Show upgrade/downgrade options
  def edit
    @current_subscription = @subscription
    @all_plans = SubscriptionPlans.all_buyer_plans
    @current_plan_type = @current_subscription&.plan_type
  end
  
  # PATCH /buyer/subscription
  # Handle plan change (upgrade/downgrade)
  def update
    new_plan_type = params[:plan_type]
    
    # Debug logging
    Rails.logger.info "=== Subscription Update Request ==="
    Rails.logger.info "Current subscription ID: #{@subscription&.id}"
    Rails.logger.info "Current plan: #{@subscription&.plan_type}"
    Rails.logger.info "New plan type: #{new_plan_type}"
    Rails.logger.info "Valid plan check: #{valid_buyer_plan?(new_plan_type)}"
    
    unless valid_buyer_plan?(new_plan_type)
      Rails.logger.error "Invalid plan type: #{new_plan_type}"
      redirect_to edit_buyer_subscription_path, alert: 'Invalid plan selected'
      return
    end
    
    # Update in Stripe first
    Rails.logger.info "Calling Stripe update for subscription: #{@subscription.stripe_subscription_id}"
    stripe_result = Payment::StripeService.update_stripe_subscription(@subscription, new_plan_type)
    
    Rails.logger.info "Stripe result: #{stripe_result.inspect}"
    
    if stripe_result[:success]
      # Update local subscription
      Rails.logger.info "Updating local subscription..."
      result = Payment::SubscriptionService.update_subscription_plan(@subscription, new_plan_type)
      
      Rails.logger.info "Local update result: #{result.inspect}"
      
      if result[:success]
        redirect_to buyer_subscription_path, notice: 'Your subscription has been updated successfully!'
      else
        Rails.logger.error "Failed to update local subscription: #{result[:error]}"
        redirect_to edit_buyer_subscription_path, alert: "Unable to update subscription: #{result[:error]}"
      end
    else
      Rails.logger.error "Stripe update failed: #{stripe_result[:error]}"
      redirect_to edit_buyer_subscription_path, alert: "Unable to update subscription: #{stripe_result[:error]}"
    end
  end
  
  # DELETE /buyer/subscription
  # Cancel subscription
  def destroy
    immediate = params[:immediate] == 'true'
    
    # Cancel in Stripe first
    stripe_result = Payment::StripeService.cancel_stripe_subscription(@subscription, immediate: immediate)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.cancel_subscription(@subscription, immediate: immediate)
      
      if result[:success]
        if immediate
          redirect_to buyer_subscription_path, notice: 'Your subscription has been cancelled immediately.'
        else
          redirect_to buyer_subscription_path, notice: 'Your subscription will be cancelled at the end of the current billing period.'
        end
      else
        redirect_to buyer_subscription_path, alert: "Unable to cancel subscription: #{result[:error]}"
      end
    else
      redirect_to buyer_subscription_path, alert: "Unable to cancel subscription: #{stripe_result[:error]}"
    end
  end
  
  # POST /buyer/subscription/reactivate
  # Reactivate a cancelled subscription
  def reactivate
    unless @subscription.cancelled?
      redirect_to buyer_subscription_path, alert: 'This subscription is not cancelled'
      return
    end
    
    # Reactivate in Stripe first
    stripe_result = Payment::StripeService.reactivate_stripe_subscription(@subscription)
    
    if stripe_result[:success]
      # Update local subscription
      result = Payment::SubscriptionService.reactivate_subscription(@subscription)
      
      if result[:success]
        redirect_to buyer_subscription_path, notice: 'Your subscription has been reactivated successfully!'
      else
        redirect_to buyer_subscription_path, alert: "Unable to reactivate subscription: #{result[:error]}"
      end
    else
      redirect_to buyer_subscription_path, alert: "Unable to reactivate subscription: #{stripe_result[:error]}"
    end
  end
  
  # GET /buyer/subscription/cancel_confirm
  # Show cancellation confirmation page
  def cancel_confirm
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to buyer_subscription_path, alert: 'No active subscription found'
    end
  end
  
  # GET /buyer/subscription/upgrade
  # Show upgrade options
  def upgrade
    @current_subscription = Payment::SubscriptionService.current_subscription(current_user)
    @all_plans = SubscriptionPlans.all_buyer_plans
    @current_plan_type = @current_subscription&.plan_type
    
    # Filter to show only upgrade options
    @upgrade_plans = filter_upgrade_plans(@current_plan_type)
  end
  
  private
  
  def set_subscription
    @subscription = Payment::SubscriptionService.current_subscription(current_user)
    
    unless @subscription
      redirect_to new_buyer_subscription_path, alert: 'No active subscription found'
    end
  end
  
  def ensure_buyer_role
    unless current_user.buyer?
      redirect_to root_path, alert: 'Access denied'
    end
  end
  
  def valid_buyer_plan?(plan_type)
    %w[buyer_starter buyer_standard buyer_premium buyer_club].include?(plan_type.to_s)
  end
  
  def filter_upgrade_plans(current_plan_type)
    return SubscriptionPlans.all_buyer_plans if current_plan_type.nil?
    
    # Define plan hierarchy
    plan_hierarchy = {
      'buyer_starter' => 1,
      'buyer_standard' => 2,
      'buyer_premium' => 3,
      'buyer_club' => 4
    }
    
    current_level = plan_hierarchy[current_plan_type.to_s] || 0
    
    SubscriptionPlans.all_buyer_plans.select do |key, _plan|
      (plan_hierarchy[key.to_s] || 0) > current_level
    end
  end
end
