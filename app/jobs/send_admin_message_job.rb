class SendAdminMessageJob < ApplicationJob
  queue_as :default
  
  def perform(admin_message_id)
    message = AdminMessage.find(admin_message_id)
    
    # Get target users based on role
    users = case message.target_role
            when 'seller' then User.sellers.active_users
            when 'buyer' then User.buyers.active_users
            when 'partner' then User.partners.active_users
            else User.where.not(role: 'admin').active_users
            end
    
    # Create recipients and send emails
    users.find_each do |user|
      recipient = message.message_recipients.create!(user: user)
      
      # Send email if enabled
      if message.send_email?
        AdminMessageMailer.broadcast_message(recipient).deliver_later
        recipient.update!(email_sent: true, email_sent_at: Time.current)
      end
    end
    
    # Update counts and mark as sent
    message.update!(
      recipients_count: message.message_recipients.count,
      sent_at: Time.current
    )
  end
end
