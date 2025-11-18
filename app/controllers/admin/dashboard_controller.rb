class Admin::DashboardController < ApplicationController
  layout 'admin'
  
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    # Admin dashboard logic
  end

  private

  def authorize_admin!
    unless current_user&.admin? && current_user&.active?
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end
end
