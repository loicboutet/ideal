# Stripe Webhook Setup for Development

## Current Issue

You're running `stripe listen` but NOT forwarding webhooks to your Rails app.

## Fix

### Step 1: Update Your .env File

Replace your current webhook secret with the one from Stripe CLI:

```bash
STRIPE_WEBHOOK_SECRET=whsec_a92c04b3f38fb2084807a5ecd7c8f09ac8008c37fd5a58ec46853afbf88bc391
```

### Step 2: Run Stripe CLI with Forwarding

Stop the current `stripe listen` (Ctrl+C) and run:

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

This will:
- Listen for Stripe events
- Forward them to your local Rails server at `/webhooks/stripe`
- Show you each event as it's processed

### Step 3: Test the Subscription Flow

1. Keep Stripe CLI running in one terminal
2. Keep your Rails server running (`bin/dev`) in another terminal
3. Go to http://localhost:3000/buyer/subscription/new
4. Click "Choose Standard"
5. Complete the test payment on Stripe
6. Watch the Stripe CLI terminal - you should see events being forwarded
7. Check your Rails logs - you should see webhook processing
8. You should be redirected to the subscription show page

### Step 4: Verify in Database

```bash
rails runner "user = User.find(10); sub = user.subscriptions.last; puts sub ? \"Subscription: #{sub.plan_type}, Status: #{sub.status}\" : 'No subscription found'"
```

## What You Should See

### In Stripe CLI Terminal:
```
> Ready! Your webhook signing secret is whsec_xxx (^C to quit)
2025-11-21 04:15:00  --> checkout.session.completed [evt_xxx]
2025-11-21 04:15:00  <--  [200] POST http://localhost:3000/webhooks/stripe [evt_xxx]
```

### In Rails Logs:
```
Processing by WebhooksController#stripe
Webhook received: checkout.session.completed
Subscription created for user 10
```

### In Browser:
You should be redirected to http://localhost:3000/buyer/subscription (subscription show page)

## Troubleshooting

If webhooks still don't work:
1. Make sure `.env` has the correct `STRIPE_WEBHOOK_SECRET`
2. Restart your Rails server after updating `.env`
3. Check Rails logs for any errors in `WebhooksController`
