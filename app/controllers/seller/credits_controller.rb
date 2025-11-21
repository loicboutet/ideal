module Seller
  class CreditsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!
    
    def index
      @current_balance = Payment::CreditService.get_balance(current_user)
      @credit_packs = CreditPack.active.ordered
      @transaction_history = current_user.seller_profile.credit_transactions.recent.limit(20)
      
      # Calculate stats
      @total_earned = @transaction_history.earned.sum(:amount)
      @total_spent = @transaction_history.spent.sum(:amount).abs
      @earned_this_month = current_user.seller_profile.credits_earned_this_month
    end
    
    def checkout
      @credit_pack = CreditPack.find(params[:pack_id])
      
      begin
        # Create Stripe checkout session
        session = Stripe::Checkout::Session.create(
          customer: get_or_create_stripe_customer,
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
          success_url: seller_credits_success_url(session_id: '{CHECKOUT_SESSION_ID}'),
          cancel_url: seller_credits_url,
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
        redirect_to seller_credits_path, alert: "Erreur lors de la création de la session de paiement. Veuillez réessayer."
      end
    end
    
    def success
      session_id = params[:session_id]
      
      begin
        session = Stripe::Checkout::Session.retrieve(session_id)
        
        if session.payment_status == 'paid'
          @message = "Paiement réussi ! Vos crédits ont été ajoutés à votre compte."
          @success = true
        else
          @message = "Le paiement est en cours de traitement. Vos crédits seront ajoutés sous peu."
          @success = false
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Error retrieving checkout session: #{e.message}"
        @message = "Erreur lors de la vérification du paiement."
        @success = false
      end
      
      @current_balance = Payment::CreditService.get_balance(current_user)
    end
    
    private
    
    def ensure_seller!
      unless current_user.seller?
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
