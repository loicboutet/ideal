class Buyer::ServicesController < ApplicationController
  layout 'buyer'
  
  before_action :authenticate_user!
  before_action :authorize_buyer!
  before_action :set_buyer_profile
  
  def sourcing
    # Sourcing personnalisé - Information page about personalized sourcing service
  end
  
  def partners
    # Partner directory access - Redirect to public partner directory
    # Free for premium subscribers
  end
  
  def tools
    # Tools and resources page
  end
  
  private
  
  def set_buyer_profile
    @buyer_profile = current_user.buyer_profile
    
    unless @buyer_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de repreneur requis.'
    end
  end
  
  def authorize_buyer!
    unless current_user&.buyer_profile
      redirect_to root_path, alert: 'Accès refusé. Privilèges de repreneur requis.'
    end
  end
end
