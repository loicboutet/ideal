module Buyer
  class CreditsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_buyer!
    
    def index
      @current_balance = Payment::CreditService.get_balance(current_user)
      @credit_packs = CreditPack.active.ordered
      @transaction_history = Payment::CreditService.transaction_history(current_user, limit: 20)
      
      # Calculate stats
      @total_earned = @transaction_history.select { |t| t.is_a?(CreditTransaction) && t.earned? }.sum(&:amount)
      @total_spent = @transaction_history.select { |t| t.is_a?(CreditTransaction) && t.spent? }.sum(&:absolute_amount)
    end
    
    def checkout
      @credit_pack = CreditPack.find(params[:pack_id])
      
      begin
        # Create Stripe checkout session
        session = Stripe::Checkout::Session.create(
          customer: get_or_create_stripe_customer,
          client_reference_id: current_user.id.to_s,
          payment_method_types: ['card'],
          line_items: [{
            price_data: {
              currency: 'eur',
              unit_amount: @credit_pack.price_cents,
              product_data: {
                name: @credit_pack.name,
                description: @credit_pack.description || "Pack de #{@credit_pack.credits_amount} crédits"
              }
            },
            quantity: 1
          }],
          mode: 'payment',
          success_url: success_buyer_credits_url(session_id: '{CHECKOUT_SESSION_ID}'),
          cancel_url: buyer_credits_url,
          metadata: {
            user_id: current_user.id,
            credit_pack_id: @credit_pack.id,
            credits_amount: @credit_pack.credits_amount,
            transaction_type: 'credit_purchase'
          }
        )
        
        redirect_to session.url, allow_other_host: true
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe checkout error: #{e.message}"
        redirect_to buyer_credits_path, alert: "Erreur lors de la création de la session de paiement. Veuillez réessayer."
      end
    end
    
    def success
      # Check if we have a valid session_id (not the placeholder)
      session_id = params[:session_id]
      
      if session_id.blank? || session_id.include?('CHECKOUT_SESSION_ID')
        # Invalid or placeholder session_id - likely accessed directly
        redirect_to buyer_credits_path, alert: "Session invalide. Veuillez effectuer un nouvel achat."
        return
      end
      
      # Payment successful - credits will be added via webhook
      @message = "Paiement réussi ! Vos crédits seront ajoutés à votre compte dans quelques instants."
      @success = true
      @current_balance = Payment::CreditService.get_balance(current_user)
      
      # Log the session_id for debugging
      Rails.logger.info "Credit purchase success page accessed by user #{current_user.id}, session: #{session_id}"
    end
    
    private
    
    def ensure_buyer!
      unless current_user.buyer?
        redirect_to root_path, alert: "Accès non autorisé"
      end
    end
    
    def get_or_create_stripe_customer
      return current_user.stripe_customer_id if current_user.stripe_customer_id.present?
      
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: current_user.full_name,
        metadata: {
          user_id: current_user.id,
          role: current_user.role
        }
      )
      
      current_user.update(stripe_customer_id: customer.id)
      customer.id
    end
  end
end
