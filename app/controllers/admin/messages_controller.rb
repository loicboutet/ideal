class Admin::MessagesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_message, only: [:show]
  
  def index
    @messages = AdminMessage.includes(:sent_by)
                           .recent
                           .page(params[:page])
                           .per(20)
    
    @stats = {
      total: AdminMessage.count,
      sent: AdminMessage.sent.count,
      unsent: AdminMessage.unsent.count,
      broadcasts: AdminMessage.broadcast.count,
      surveys: AdminMessage.survey.count
    }
  end
  
  def new
    @message = AdminMessage.new
    @message.message_type = params[:type] || 'broadcast'
  end
  
  def create
    @message = AdminMessage.new(message_params)
    @message.sent_by = current_user
    
    if @message.save
      # Send message asynchronously
      SendAdminMessageJob.perform_later(@message.id)
      redirect_to admin_messages_path, notice: "Message envoyé avec succès."
    else
      render :new
    end
  end
  
  def show
    @recipients = @message.message_recipients
                         .includes(:user)
                         .page(params[:page])
                         .per(50)
  end
  
  private
  
  def set_message
    @message = AdminMessage.find(params[:id])
  end
  
  def message_params
    params.require(:admin_message).permit(
      :subject,
      :body,
      :message_type,
      :target_role,
      :send_email,
      :show_in_dashboard
    )
  end
  
  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
