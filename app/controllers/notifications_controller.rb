class NotificationsController < ApplicationController
  before_action :authenticate_user!
  layout :resolve_layout
  
  def index
    @notifications = current_user.message_recipients
                                 .includes(:admin_message)
                                 .order(created_at: :desc)
                                 .page(params[:page])
                                 .per(20)
    
    # Count statistics
    @unread_count = current_user.message_recipients.unread.count
    @total_count = current_user.message_recipients.count
  end
  
  def show
    @message_recipient = current_user.message_recipients.find(params[:id])
    @admin_message = @message_recipient.admin_message
    
    # Mark as read
    @message_recipient.mark_as_read! unless @message_recipient.read?
  end
  
  def mark_all_as_read
    current_user.message_recipients.unread.each(&:mark_as_read!)
    
    redirect_to notifications_path, notice: 'Toutes les notifications ont été marquées comme lues.'
  end

  private

  def resolve_layout
    case current_user&.role
    when 'admin'
      'admin'
    when 'seller'
      'seller'
    when 'buyer'
      'buyer'
    when 'partner'
      'partner'
    else
      'application'
    end
  end
end
