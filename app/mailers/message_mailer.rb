class MessageMailer < ApplicationMailer
  def new_message_notification(message, recipient)
    @message = message
    @sender = message.sender
    @recipient = recipient
    @conversation = message.conversation
    
    # Determine the conversation URL based on recipient role using Rails URL helpers
    @conversation_url = conversation_url_for_recipient(recipient)
    
    mail(
      to: recipient.email,
      subject: "Nouveau message de #{@sender.full_name}"
    )
  end
  
  private
  
  def conversation_url_for_recipient(recipient)
    # Use Rails URL helpers which automatically read from default_url_options
    case recipient.role
    when 'buyer'
      buyer_conversation_url(@conversation)
    when 'seller'
      seller_conversation_url(@conversation)
    when 'partner'
      partner_conversation_url(@conversation)
    else
      root_url
    end
  end
end
