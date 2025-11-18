class Seller::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_seller!

  def index
    # Seller dashboard logic
  end

  private

  def authorize_seller!
    unless current_user&.seller? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Seller privileges required.'
    end
  end
end
