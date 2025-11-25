class Admin::SubscriptionWebhookLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_log, only: [:show, :destroy]

  def index
    @logs = SubscriptionWebhookLog.includes(:user)
                                    .recent
                                    .by_user(params[:user_id])
                                    .by_event_type(params[:event_type])
                                    .by_status(params[:status])
                                    .page(params[:page])
                                    .per(50)
    
    # Get unique event types for filter
    @event_types = SubscriptionWebhookLog.distinct.pluck(:event_type).sort
  end

  def show
    # @log is set by before_action
  end

  def destroy
    @log.destroy
    redirect_to admin_subscription_webhook_logs_path, notice: 'Webhook log deleted successfully.'
  end

  private

  def set_log
    @log = SubscriptionWebhookLog.find(params[:id])
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end
