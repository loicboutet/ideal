module SubscriptionGate
  extend ActiveSupport::Concern
  
  included do
    # Make helper methods available in views
    helper_method :current_user_plan, :user_has_feature?, :user_within_limit?
  end
  
  # Check if user has an active subscription (not free tier)
  def require_active_subscription
    unless current_user.subscription_active?
      redirect_to upgrade_path, alert: "Cette fonctionnalité nécessite un abonnement actif."
      return false
    end
    true
  end
  
  # Check if user has a specific plan
  def require_plan(plan_name)
    unless current_user.has_plan?(plan_name)
      redirect_to upgrade_path, alert: "Cette fonctionnalité nécessite le forfait #{plan_name.to_s.titleize}."
      return false
    end
    true
  end
  
  # Check if user can access a specific feature
  def require_feature(feature_name)
    unless current_user.can_access_feature?(feature_name)
      redirect_to upgrade_path, alert: "Cette fonctionnalité nécessite un forfait supérieur."
      return false
    end
    true
  end
  
  # Check if user has sufficient credits
  def require_credits(amount)
    unless current_user.has_sufficient_credits?(amount)
      flash[:alert] = "Crédits insuffisants. Vous avez besoin de #{amount} crédit(s) mais n'en avez que #{current_user.credits_balance}."
      redirect_to insufficient_credits_path(required: amount, current: current_user.credits_balance)
      return false
    end
    true
  end
  
  # Check if user is within a feature limit
  def require_within_limit(feature_name, current_count)
    unless current_user.within_limit?(feature_name, current_count)
      limit = current_user.feature_limit(feature_name)
      redirect_to upgrade_path, 
        alert: "Vous avez atteint la limite de #{limit} pour #{feature_name}. Passez à un forfait supérieur pour continuer."
      return false
    end
    true
  end
  
  # Helper methods for views
  def current_user_plan
    current_user.subscription_plan
  end
  
  def user_has_feature?(feature_name)
    current_user.can_access_feature?(feature_name)
  end
  
  def user_within_limit?(feature_name, current_count)
    current_user.within_limit?(feature_name, current_count)
  end
  
  private
  
  def upgrade_path
    case current_user.role
    when 'buyer'
      new_buyer_subscription_path
    when 'seller'
      new_seller_subscription_path
    when 'partner'
      new_partner_subscription_path
    else
      root_path
    end
  end
  
  def insufficient_credits_path(params = {})
    case current_user.role
    when 'buyer'
      buyer_credits_path(params)
    when 'seller'
      seller_credits_path(params)
    else
      root_path
    end
  end
end
