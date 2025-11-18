# Preview all emails at http://localhost:3000/rails/mailers/listing_notification_mailer
class ListingNotificationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/listing_notification_mailer/listing_approved
  def listing_approved
    ListingNotificationMailer.listing_approved
  end

  # Preview this email at http://localhost:3000/rails/mailers/listing_notification_mailer/listing_rejected
  def listing_rejected
    ListingNotificationMailer.listing_rejected
  end
end
