# frozen_string_literal: true

# Configure Postmark for email delivery
Rails.application.config.action_mailer.delivery_method = :postmark
Rails.application.config.action_mailer.postmark_settings = {
  api_token: Rails.application.credentials.postmark_api_token
}
