# Stripe Price ID Fix - Deployment Guide

## Issue Fixed
The error "No such price: 'price_YOUR_PRODUCTION_STANDARD_PRICE'" was occurring because the application was using placeholder Stripe price IDs instead of real ones.

## Changes Made

### 1. Updated config/initializers/subscription_plans.rb
- Changed all Stripe price IDs to use `Rails.application.credentials.dig(:stripe, :buyer_starter_price_id)` format
- This means price IDs are now loaded from Rails credentials instead of ENV variables

### 2. Updated config/deploy.yml
- Removed all Stripe-related environment variables (publishable_key, price_ids)
- Now only passes `RAILS_MASTER_KEY` to the application
- All Stripe configuration is loaded from credentials.yml via the master key

### 3. Updated .kamal/secrets
- Removed `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET`
- Only `RAILS_MASTER_KEY` is needed for deployment

### 4. Stripe Configuration Flow
```
Deploy → RAILS_MASTER_KEY → credentials.yml → Stripe API keys & Price IDs
```

## Current Credentials (TEST Mode)
The credentials file contains:
- `stripe.publishable_key`: pk_test_51Qo0uCFaXzFtpl3S...
- `stripe.secret_key`: sk_test_51Qo0uCFaXzFtpl3S...
- `stripe.webhook_secret`: whsec_a92c04b3f38fb2084...
- `stripe.buyer_starter_price_id`: price_1SVs61C0TM4Nm4RRE0IbeSJ8
- `stripe.buyer_standard_price_id`: price_1SVeq3C0TM4RRpDdh9QNR
- `stripe.buyer_premium_price_id`: price_1SVeqVC0TM4Nm4RRumraJXFg
- `stripe.buyer_club_price_id`: price_1SVes3C0TM4RRusaus6tx
- `stripe.seller_premium_price_id`: price_1SVesWC0TM4RRHFvXY0LI
- `stripe.partner_annual_price_id`: price_1SVetVC0TM4Nm4RRUT1lQQqx

## Deployment Steps

### 1. Set Environment Variables
Before deploying, ensure these environment variables are set:
```bash
export RAILS_MASTER_KEY=f412ee9fb8b3dbb4fca5fcb70385d53f
export KAMAL_REGISTRY_PASSWORD=<your_docker_hub_password>
```

### 2. Deploy with Kamal
```bash
kamal deploy
```

This will:
1. Build the Docker image with the updated code
2. Push it to Docker Hub
3. Deploy to the staging server (141.94.197.228)
4. Pass only RAILS_MASTER_KEY as a secret
5. The app will decrypt credentials and load all Stripe config

### 3. Verify Deployment
After deployment, test the subscription functionality:
1. Visit https://ideal.5000.dev/buyer/subscription/edit
2. Try changing subscription plans
3. The error "No such price" should be gone
4. Stripe checkout should work with the real test price IDs

## How It Works Now

1. **Initialization**: When Rails starts, it uses `RAILS_MASTER_KEY` to decrypt `config/credentials.yml.enc`
2. **Stripe Setup**: `config/initializers/stripe.rb` loads API keys from credentials
3. **Price IDs**: `config/initializers/subscription_plans.rb` loads price IDs from credentials
4. **Checkout**: When user clicks to change plan, StripeService uses the real price ID from credentials

## Benefits of This Approach

✅ **Single Source of Truth**: All Stripe config in one encrypted file
✅ **Secure**: Only master key needed for deployment, not individual secrets
✅ **Version Controlled**: credentials.yml.enc can be safely committed to git
✅ **Easy Updates**: Edit credentials with `EDITOR=nano rails credentials:edit`
✅ **Environment Specific**: Same master key works across environments

## Future: Moving to Production

When ready for production with LIVE Stripe keys:
1. Create LIVE products/prices in Stripe Dashboard
2. Edit credentials: `EDITOR=nano rails credentials:edit`
3. Update the stripe section with LIVE keys and price IDs
4. Redeploy - no other changes needed!

## Troubleshooting

### If deployment fails:
```bash
# Check logs
kamal app logs

# Check if master key is set
kamal app exec --interactive --reuse "printenv | grep RAILS_MASTER_KEY"

# Access Rails console
kamal app exec --interactive --reuse "bin/rails console"
# Then run: Rails.application.credentials.stripe
```

### If price IDs are nil in console:
```ruby
# In rails console on server:
Rails.application.credentials.dig(:stripe, :buyer_standard_price_id)
# Should return: "price_1SVeq3C0TM4RRpDdh9QNR"
```

## Notes
- This is a TEST/staging environment using Stripe test mode
- No real payments will be processed
- Test card: 4242 4242 4242 4242 (any future expiry, any CVC)
