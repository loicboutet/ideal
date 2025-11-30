# frozen_string_literal: true

# CheckoutController
# Handles subscription and payment flow - critical for revenue generation
# Integrates with Stripe for payment processing
class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plans
  
  layout 'mockup'
  
  # GET /checkout/select_plan
  # Display available subscription plans based on user role
  def select_plan
    @current_subscription = current_user_subscription
    @user_role = current_user.role
  end
  
  # GET /checkout/payment
  # Display payment form for selected plan
  def payment_form
    @selected_plan = find_plan(params[:plan])
    
    unless @selected_plan
      flash[:alert] = "Plan sélectionné invalide."
      redirect_to checkout_select_plan_path
      return
    end
    
    @billing_details = {
      name: current_user.full_name,
      email: current_user.email,
      plan: @selected_plan
    }
  end
  
  # POST /checkout/process_payment
  # Process payment via Stripe and create subscription
  def process_payment
    @selected_plan = find_plan(params[:plan])
    
    unless @selected_plan
      flash[:alert] = "Plan invalide."
      redirect_to checkout_select_plan_path
      return
    end
    
    # In production, this would integrate with Stripe
    # For now, we simulate a successful payment
    begin
      # Stripe integration would go here:
      # customer = Stripe::Customer.create(email: current_user.email)
      # subscription = Stripe::Subscription.create(customer: customer.id, items: [{price: @selected_plan[:stripe_price_id]}])
      
      # Create local subscription record
      create_subscription(@selected_plan)
      
      # Award credits if included in plan
      award_plan_credits(@selected_plan) if @selected_plan[:credits]
      
      # Log the transaction
      log_transaction(@selected_plan)
      
      flash[:notice] = "Votre abonnement #{@selected_plan[:name]} a été activé avec succès !"
      redirect_to checkout_success_path(plan: params[:plan])
    rescue StandardError => e
      Rails.logger.error "Payment processing error: #{e.message}"
      flash[:alert] = "Une erreur est survenue lors du paiement. Veuillez réessayer."
      redirect_to checkout_cancel_path
    end
  end
  
  # GET /checkout/success
  # Display success page after successful payment
  def success
    @plan = find_plan(params[:plan]) || default_plan_for_role
  end
  
  # GET /checkout/cancel
  # Display cancellation/failure page
  def cancel
    @reason = params[:reason] || 'cancelled'
  end
  
  private
  
  def set_plans
    @buyer_plans = [
      {
        id: 'buyer_basic',
        name: 'Essentiel',
        price: 89,
        period: 'mois',
        features: [
          'Accès à toutes les annonces',
          'Signature NDA illimitée',
          '5 contacts vendeurs/mois',
          'CRM basique',
          'Support email'
        ],
        popular: false,
        stripe_price_id: 'price_buyer_basic'
      },
      {
        id: 'buyer_pro',
        name: 'Professionnel',
        price: 199,
        period: 'mois',
        features: [
          'Tout Essentiel +',
          '15 contacts vendeurs/mois',
          'Annonces exclusives',
          'CRM avancé (10 étapes)',
          'Alertes personnalisées',
          'Support prioritaire'
        ],
        popular: true,
        credits: 10,
        stripe_price_id: 'price_buyer_pro'
      },
      {
        id: 'buyer_club',
        name: 'Club',
        price: 1200,
        period: 'an',
        features: [
          'Tout Professionnel +',
          'Contacts illimités',
          'Réservation prioritaire (2 mois)',
          'Accès aux deals premium',
          'Accompagnement dédié',
          'Formation reprise offerte'
        ],
        popular: false,
        credits: 50,
        stripe_price_id: 'price_buyer_club'
      }
    ]
    
    @seller_plans = [
      {
        id: 'seller_basic',
        name: 'Gratuit',
        price: 0,
        period: 'mois',
        features: [
          '1 annonce active',
          '3 contacts repreneurs gratuits',
          'Validation manuelle',
          'Support email'
        ],
        popular: false,
        stripe_price_id: nil
      },
      {
        id: 'seller_premium',
        name: 'Premium',
        price: 149,
        period: 'mois',
        features: [
          'Annonces illimitées',
          'Contacts repreneurs illimités',
          'Mise en avant des annonces',
          'Accès annuaire repreneurs',
          'Analytics détaillées',
          'Support prioritaire'
        ],
        popular: true,
        credits: 20,
        stripe_price_id: 'price_seller_premium'
      }
    ]
    
    @partner_plans = [
      {
        id: 'partner_annual',
        name: 'Annuaire Partenaire',
        price: 590,
        period: 'an',
        features: [
          'Profil visible dans l\'annuaire',
          'Page partenaire dédiée',
          'Lien Google Agenda',
          'Badge vérifié',
          'Analytics de contacts',
          'Support dédié'
        ],
        popular: true,
        stripe_price_id: 'price_partner_annual'
      }
    ]
    
    @credit_packs = [
      { id: 'credits_5', name: '5 crédits', price: 25, credits: 5 },
      { id: 'credits_15', name: '15 crédits', price: 60, credits: 15, discount: '20%' },
      { id: 'credits_30', name: '30 crédits', price: 100, credits: 30, discount: '33%' }
    ]
  end
  
  def find_plan(plan_id)
    return nil unless plan_id
    
    all_plans = (@buyer_plans || []) + (@seller_plans || []) + (@partner_plans || []) + (@credit_packs || [])
    all_plans.find { |p| p[:id] == plan_id }
  end
  
  def default_plan_for_role
    case current_user.role
    when 'buyer'
      @buyer_plans&.find { |p| p[:popular] } || @buyer_plans&.first
    when 'seller'
      @seller_plans&.find { |p| p[:popular] } || @seller_plans&.first
    when 'partner'
      @partner_plans&.first
    else
      nil
    end
  end
  
  def current_user_subscription
    case current_user.role
    when 'buyer'
      current_user.buyer_profile&.subscription_status
    when 'seller'
      # SellerProfile may not have subscription_status, check if method exists
      profile = current_user.seller_profile
      profile.respond_to?(:subscription_status) ? profile&.subscription_status : nil
    when 'partner'
      current_user.partner_profile&.directory_subscription_expires_at
    end
  rescue NoMethodError
    nil
  end
  
  def create_subscription(plan)
    # Update the user's profile with subscription info
    # This would be more robust in production
    case current_user.role
    when 'buyer'
      if profile = current_user.buyer_profile
        if profile.respond_to?(:subscription_status=)
          profile.update(
            subscription_status: plan[:id],
            subscription_expires_at: calculate_expiration(plan[:period])
          )
        end
      end
    when 'seller'
      if profile = current_user.seller_profile
        if profile.respond_to?(:subscription_status=)
          profile.update(
            subscription_status: plan[:id],
            subscription_expires_at: calculate_expiration(plan[:period])
          )
        end
      end
    when 'partner'
      if profile = current_user.partner_profile
        profile.update(
          directory_subscription_expires_at: calculate_expiration(plan[:period])
        )
      end
    end
  rescue StandardError => e
    Rails.logger.warn "Could not update subscription: #{e.message}"
  end
  
  def calculate_expiration(period)
    case period
    when 'mois'
      1.month.from_now
    when 'an'
      1.year.from_now
    else
      1.month.from_now
    end
  end
  
  def award_plan_credits(plan)
    return unless plan[:credits]
    
    # Award credits to user profile
    case current_user.role
    when 'buyer'
      if profile = current_user.buyer_profile
        profile.increment!(:credits, plan[:credits]) if profile.respond_to?(:credits)
      end
    when 'seller'
      if profile = current_user.seller_profile
        profile.increment!(:credits, plan[:credits]) if profile.respond_to?(:credits)
      end
    end
  rescue StandardError => e
    Rails.logger.warn "Could not award credits: #{e.message}"
  end
  
  def log_transaction(plan)
    # In production, create a Payment record
    Rails.logger.info "Payment processed: User #{current_user.id} subscribed to #{plan[:id]} for #{plan[:price]}€"
  end
end
