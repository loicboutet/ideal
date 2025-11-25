# Stripe Publishable Key Fix - Production Deployment Guide

## Issue Description
On production (https://ideal.5000.dev/seller/subscription/new), users were seeing the error:
```
IntegrationError: Please call Stripe() with your publishable key. You used an empty string.
```

This occurred because the view was trying to read the Stripe publishable key from `ENV['STRIPE_PUBLISHABLE_KEY']`, which is not set in the production environment variables.

## Root Cause
The view `app/views/seller/subscriptions/new.html.erb` was using:
```erb
ENV['STRIPE_PUBLISHABLE_KEY']
```

Instead of using the Rails configuration that reads from credentials:
```erb
Rails.configuration.stripe[:publishable_key]
```

## Fix Applied

### Code Change
Updated `app/views/seller/subscriptions/new.html.erb` to use `Rails.configuration.stripe[:publishable_key]` instead of `ENV['STRIPE_PUBLISHABLE_KEY']`.

**Before:**
```erb
stripe_subscription_publishable_key_value: ENV['STRIPE_PUBLISHABLE_KEY'],
```

**After:**
```erb
stripe_subscription_publishable_key_value: Rails.configuration.stripe[:publishable_key],
```

This ensures the view uses the same credential source as the rest of the application (defined in `config/initializers/stripe.rb`).

## Deployment Instructions

### Step 1: Verify Production Credentials
On the production server, ensure the production credentials file contains the Stripe configuration:

```bash
# SSH to production server
EDITOR="cat" bin/rails credentials:show --environment production
```

You should see a `stripe:` section with at minimum:
```yaml
stripe:
  publishable_key: pk_live_xxxxx  # or pk_test_xxxxx for test mode
  secret_key: sk_live_xxxxx       # or sk_test_xxxxx for test mode
  webhook_secret: whsec_xxxxx
  # ... other price IDs
```

### Step 2: Update Production Credentials (If Needed)
If the Stripe credentials are missing or incorrect, update them:

```bash
# On production server
EDITOR="vim" bin/rails credentials:edit --environment production
```

Add or update the Stripe section with your production values:
```yaml
stripe:
  publishable_key: pk_live_YOUR_PRODUCTION_KEY
  secret_key: sk_live_YOUR_PRODUCTION_KEY
  webhook_secret: whsec_YOUR_PRODUCTION_WEBHOOK_SECRET
  buyer_starter_price_id: price_xxxxx
  buyer_standard_price_id: price_xxxxx
  buyer_premium_price_id: price_xxxxx
  buyer_club_price_id: price_xxxxx
  seller_premium_price_id: price_xxxxx
  partner_annual_price_id: price_xxxxx
```

**Important:** 
- Use **live mode keys** (pk_live_/sk_live_) for production
- Use **test mode keys** (pk_test_/sk_test_) for testing in production
- The webhook secret should come from your Stripe Dashboard webhook endpoint, not Stripe CLI

### Step 3: Commit and Deploy the Code Change

```bash
# On local machine
git add app/views/seller/subscriptions/new.html.erb
git commit -m "Fix: Use Rails.configuration for Stripe publishable key instead of ENV variable"
git push origin main
```

### Step 4: Deploy to Production
Deploy using your deployment method (Kamal, Capistrano, etc.):

```bash
# Example with Kamal
bin/kamal deploy

# Or manual deployment
# SSH to server and pull changes, then restart
```

### Step 5: Restart Production Application
After deployment, restart the Rails application to ensure the new code is loaded:

```bash
# On production server (method depends on your setup)
sudo systemctl restart puma
# or
touch tmp/restart.txt
# or restart via your container orchestration
```

### Step 6: Verify the Fix
1. Visit https://ideal.5000.dev/seller/subscription/new
2. Open browser console (F12)
3. Check that no Stripe integration errors appear
4. The Stripe card input field should render correctly
5. Check Rails logs for the initialization message:
   ```
   Stripe initialized with publishable key: pk_live_xxxxx...
   ```

## Testing Checklist

- [ ] Code deployed to production
- [ ] Production credentials contain Stripe publishable_key
- [ ] Application restarted
- [ ] No console errors on /seller/subscription/new
- [ ] Stripe Elements card input displays correctly
- [ ] Rails logs show "Stripe initialized with publishable key: pk_..."

## Rollback Plan
If issues occur, you can quickly rollback by:

1. Revert the git commit:
   ```bash
   git revert HEAD
   git push origin main
   ```

2. Redeploy the previous version

## Related Files Changed
- `app/views/seller/subscriptions/new.html.erb` - Primary fix

## Configuration Files (No Changes)
- `config/initializers/stripe.rb` - Already correctly configured to read from credentials
- `config/credentials/production.yml.enc` - Should contain Stripe keys (verify on server)

## Notes
- The local .env file is NOT used in production
- All production secrets should be in Rails credentials
- This fix makes the view consistent with how the rest of the application accesses Stripe configuration
- Works correctly in both development (using .env as fallback) and production (using credentials)
