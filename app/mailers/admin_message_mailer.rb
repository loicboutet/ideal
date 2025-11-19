class AdminMessageMailer < ApplicationMailer
  default from: 'noreply@ideal-reprise.com'
  
  def broadcast_message(message_recipient)
    @message = message_recipient.admin_message
    @user = message_recipient.user
    @recipient = message_recipient
    
    mail(
      to: @user.email,
      subject: @message.subject
    )
  end
  
  def survey_invitation(message_recipient)
    @message = message_recipient.admin_message
    @survey = @message.survey
    @user = message_recipient.user
    @recipient = message_recipient
    
    mail(
      to: @user.email,
      subject: "Nouveau sondage: #{@survey.title}"
    )
  end
end
