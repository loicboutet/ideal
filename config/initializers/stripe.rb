# Stripe Configuration
# Ensure you set your API keys in credentials or environment variables

Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key) || ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_SECRET_KEY'],
  webhook_secret: Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV['STRIPE_WEBHOOK_SECRET']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Set API version for consistency
Stripe.api_version = '2024-11-20.acacia'

# Note: Webhook secret is stored in Rails.configuration.stripe[:webhook_secret]
# and will be used for signature verification in the webhook controller

Rails.logger.info "Stripe initialized with publishable key: #{Rails.configuration.stripe[:publishable_key]&.truncate(20)}..."
