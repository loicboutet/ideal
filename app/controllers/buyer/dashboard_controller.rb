class Buyer::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_buyer!

  def index
    # Buyer dashboard logic
  end

  private

  def authorize_buyer!
    unless current_user&.buyer? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Buyer privileges required.'
    end
  end
end
