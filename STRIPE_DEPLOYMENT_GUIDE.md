# Stripe Deployment Guide

This guide explains how to configure Stripe environment variables for production deployment using Kamal.

## Overview

Your application uses Stripe for:
- Subscription payments (Buyer, Seller, Partner plans)
- Credit purchases
- Webhook notifications

## Configuration Files Modified

- **config/deploy.yml**: Updated to include Stripe environment variables
- **.kamal/secrets**: Updated to reference Stripe secret keys from environment

## Step-by-Step Deployment Process

### 1. Get Production Stripe Keys

1. Log into your [Stripe Dashboard](https://dashboard.stripe.com/)
2. Switch to **Live mode** (toggle in top-right of dashboard)
3. Go to **Developers** → **API keys**
4. Copy your **Publishable key** (starts with `pk_live_`)
5. Click **Reveal test key** for your **Secret key** (starts with `sk_live_`)

### 2. Create Production Price IDs

You need to create production versions of all your subscription plans and credit packs:

#### Create Products and Prices

1. Go to **Products** in Stripe Dashboard (Live mode)
2. Create the following products with pricing:

**Buyer Subscriptions:**
- Buyer Starter Plan (monthly recurring)
- Buyer Standard Plan (monthly recurring)
- Buyer Premium Plan (monthly recurring)
- Buyer Club Plan (monthly recurring)

**Seller Subscription:**
- Seller Premium Plan (monthly recurring)

**Partner Subscription:**
- Partner Annual Plan (yearly recurring)

3. After creating each product/price, copy the **Price ID** (starts with `price_`)

### 3. Set Up Production Webhook Endpoint

1. In Stripe Dashboard (Live mode), go to **Developers** → **Webhooks**
2. Click **Add endpoint**
3. Set endpoint URL to: `https://ideal.5000.dev/webhooks/stripe`
4. Select events to listen for:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.paid`
   - `invoice.payment_failed`
5. Click **Add endpoint**
6. Copy the **Signing secret** (starts with `whsec_`)

### 4. Configure Environment Variables on Deployment Server

Set the following environment variables on your deployment machine or CI/CD environment:

```bash
# Export these before running kamal deploy
export STRIPE_SECRET_KEY="sk_live_YOUR_ACTUAL_SECRET_KEY"
export STRIPE_WEBHOOK_SECRET="whsec_YOUR_ACTUAL_WEBHOOK_SECRET"
export KAMAL_REGISTRY_PASSWORD="your_docker_registry_password"
export RAILS_MASTER_KEY="your_rails_master_key"
```

**IMPORTANT:** Never commit these values to git. They should only exist in:
- Your local environment variables
- Your server's environment variables
- A secure password manager (recommended)

### 5. Update config/deploy.yml with Production Values

Edit `config/deploy.yml` and replace the placeholder values in the `clear` section:

```yaml
env:
  clear:
    # Stripe Configuration (non-sensitive keys)
    STRIPE_PUBLISHABLE_KEY: pk_live_YOUR_ACTUAL_PUBLISHABLE_KEY
    STRIPE_BUYER_STARTER_PRICE_ID: price_YOUR_ACTUAL_STARTER_PRICE
    STRIPE_BUYER_STANDARD_PRICE_ID: price_YOUR_ACTUAL_STANDARD_PRICE
    STRIPE_BUYER_PREMIUM_PRICE_ID: price_YOUR_ACTUAL_PREMIUM_PRICE
    STRIPE_BUYER_CLUB_PRICE_ID: price_YOUR_ACTUAL_CLUB_PRICE
    STRIPE_SELLER_PREMIUM_PRICE_ID: price_YOUR_ACTUAL_SELLER_PREMIUM_PRICE
    STRIPE_PARTNER_ANNUAL_PRICE_ID: price_YOUR_ACTUAL_PARTNER_ANNUAL_PRICE
```

### 6. Deploy with Kamal

Once environment variables are set:

```bash
# Test that secrets are properly configured
kamal secrets list

# Deploy the application
kamal deploy
```

## Environment Variable Summary

### Secret Variables (from .kamal/secrets)
These are pulled from your shell environment:

| Variable | Description | Format | Source |
|----------|-------------|--------|--------|
| `STRIPE_SECRET_KEY` | Stripe secret API key | `sk_live_...` | Stripe Dashboard → API Keys |
| `STRIPE_WEBHOOK_SECRET` | Webhook signing secret | `whsec_...` | Stripe Dashboard → Webhooks |

### Clear Variables (from config/deploy.yml)
These are defined directly in deploy.yml:

| Variable | Description | Format | Source |
|----------|-------------|--------|--------|
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key | `pk_live_...` | Stripe Dashboard → API Keys |
| `STRIPE_BUYER_STARTER_PRICE_ID` | Buyer Starter plan price ID | `price_...` | Stripe Dashboard → Products |
| `STRIPE_BUYER_STANDARD_PRICE_ID` | Buyer Standard plan price ID | `price_...` | Stripe Dashboard → Products |
| `STRIPE_BUYER_PREMIUM_PRICE_ID` | Buyer Premium plan price ID | `price_...` | Stripe Dashboard → Products |
| `STRIPE_BUYER_CLUB_PRICE_ID` | Buyer Club plan price ID | `price_...` | Stripe Dashboard → Products |
| `STRIPE_SELLER_PREMIUM_PRICE_ID` | Seller Premium plan price ID | `price_...` | Stripe Dashboard → Products |
| `STRIPE_PARTNER_ANNUAL_PRICE_ID` | Partner Annual plan price ID | `price_...` | Stripe Dashboard → Products |

## Verification After Deployment

### 1. Check Environment Variables in Container

```bash
kamal app exec --interactive "env | grep STRIPE"
```

You should see all Stripe variables listed.

### 2. Test Stripe Integration

1. Visit your production site: https://ideal.5000.dev
2. Try to subscribe to a plan
3. Complete a test payment using Stripe test credit card
4. Check Stripe Dashboard → Events to see if webhook was received
5. Check application logs: `kamal app logs -f`

### 3. Monitor Webhooks

In Stripe Dashboard (Live mode):
1. Go to **Developers** → **Webhooks**
2. Click on your webhook endpoint
3. View recent deliveries and their status
4. Verify successful deliveries (200 status code)

## Troubleshooting

### Webhooks Not Received

1. **Check webhook URL**: Ensure it's `https://ideal.5000.dev/webhooks/stripe`
2. **Verify webhook secret**: Ensure `STRIPE_WEBHOOK_SECRET` matches the signing secret in Stripe Dashboard
3. **Check logs**: `kamal app logs -f` to see webhook processing
4. **Test endpoint**: Use Stripe CLI to send test events:
   ```bash
   stripe trigger checkout.session.completed --forward-to https://ideal.5000.dev/webhooks/stripe
   ```

### Invalid API Key Errors

1. **Verify environment**: Ensure using **Live mode** keys (not test mode)
2. **Check secret key**: Ensure `STRIPE_SECRET_KEY` starts with `sk_live_`
3. **Redeploy**: After updating secrets: `kamal deploy`

### Price Not Found Errors

1. **Verify price IDs**: Ensure all price IDs in `config/deploy.yml` exist in Live mode
2. **Check product status**: Ensure products are **Active** in Stripe Dashboard
3. **Verify pricing**: Ensure prices match expected amounts

## Security Best Practices

1. ✅ **Never commit secrets to git**
   - Keep `.env` in `.gitignore`
   - Use environment variables for production
   
2. ✅ **Use different keys for development and production**
   - Test mode keys (`pk_test_`, `sk_test_`) for development
   - Live mode keys (`pk_live_`, `sk_live_`) for production
   
3. ✅ **Rotate keys regularly**
   - Stripe allows creating multiple API keys
   - Update environment variables and redeploy
   
4. ✅ **Monitor webhook signatures**
   - Always verify webhook signatures using `STRIPE_WEBHOOK_SECRET`
   - Reject webhooks with invalid signatures

5. ✅ **Use a password manager**
   - Store production secrets in 1Password, LastPass, etc.
   - Reference them in deployment scripts

## Additional Resources

- [Stripe API Keys Documentation](https://stripe.com/docs/keys)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)
- [Kamal Environment Variables](https://kamal-deploy.org/docs/configuration/environment-variables/)
