class Partner::DashboardController < ApplicationController
  layout 'mockup_partner'
  
  before_action :authenticate_user!
  before_action :authorize_partner!

  def index
    # Partner dashboard logic
  end

  private

  def authorize_partner!
    unless current_user&.partner? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Partner privileges required.'
    end
  end
end
