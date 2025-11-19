class Partner::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_partner
  before_action :set_partner_profile
  layout 'partner'

  def show
    @subscription = current_user.subscriptions.where(plan_type: :partner_directory).order(created_at: :desc).first
    
    # Calculate stats for last 30 days
    @stats = calculate_stats
  end

  def update
    # Handle subscription updates (e.g., changing payment method)
    # TODO: Implement Stripe integration
    redirect_to partner_subscription_path, notice: 'Abonnement mis à jour avec succès.'
  end

  def destroy
    # Cancel subscription
    @subscription = current_user.subscriptions.where(plan_type: :partner_directory, status: :active).first
    
    if @subscription
      @subscription.update(status: :cancelled)
      redirect_to partner_subscription_path, notice: 'Votre abonnement a été annulé. Il restera actif jusqu\'à la fin de la période payée.'
    else
      redirect_to partner_subscription_path, alert: 'Aucun abonnement actif trouvé.'
    end
  end

  def renew_form
    @subscription = current_user.subscriptions.where(plan_type: :partner_directory).order(created_at: :desc).first
  end

  def renew
    # Process renewal
    # TODO: Implement Stripe payment integration
    
    # For now, create a new subscription or extend existing one
    redirect_to partner_subscription_path, notice: 'Abonnement renouvelé avec succès.'
  end

  private

  def ensure_partner
    unless current_user.role == 'partner'
      redirect_to root_path, alert: 'Accès non autorisé.'
    end
  end

  def set_partner_profile
    @partner_profile = current_user.partner_profile
    unless @partner_profile
      redirect_to root_path, alert: 'Profil partenaire introuvable.'
    end
  end

  def calculate_stats
    # Calculate stats for last 30 days
    # These would come from actual tracking models (PartnerContact, PartnerView, etc.)
    # For now, return placeholders
    {
      views_30d: 0,
      views_evolution: 0,
      contacts_30d: 0,
      contacts_evolution: 0,
      conversion_rate: 0.0,
      conversion_evolution: 0.0
    }
  end
end
