class ContactMailer < ApplicationMailer
  def contact_message(params)
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @email = params[:email]
    @phone = params[:phone]
    @user_type = params[:user_type]
    @subject = params[:subject]
    @message = params[:message]
    @newsletter = params[:newsletter]
    
    mail(
      to: 'contact@ideal-reprise.fr',
      from: 'noreply@ideal-reprise.fr',
      reply_to: @email,
      subject: "Contact Form: #{@subject}"
    )
  end
end
