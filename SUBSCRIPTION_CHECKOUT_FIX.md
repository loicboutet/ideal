# Subscription Checkout Issue Analysis & Fix

**Date:** November 21, 2025 03:58

## Issue Report

The user reported getting an "error" when creating a subscription at `/buyer/subscription`:

```
Started POST "/buyer/subscription" for ::1 at 2025-11-21 03:58:53 +0600
Processing by Buyer::SubscriptionsController#create as TURBO_STREAM
Parameters: {"authenticity_token"=>"[FILTERED]", "plan_type"=>"buyer_premium"}
...
Redirected to https://checkout.stripe.com/c/pay/cs_test_a1pH5NzbAVcbQ0PWiSAHkfpMfBMGIz73ATnf6CF2x7VcP1uNulJB2QClg2#...
Completed 302 Found in 1040ms
```

## Analysis

### NOT an Error!

The `302 Found` redirect to Stripe Checkout is **the expected and correct behavior**. The subscription flow works as follows:

1. User selects a plan on the site
2. POST to `/buyer/subscription` creates a Stripe Checkout session
3. Server redirects (302) to Stripe's hosted checkout page
4. User completes payment on Stripe
5. Stripe redirects back to success URL
6. Stripe webhook notifies our server of completion
7. Our webhook handler creates the subscription record

The 302 redirect means the Stripe Checkout session was created successfully.

## Critical Bug Found

While the redirect itself is correct, there was a **critical integration bug** that would cause the webhook handling to fail:

### The Problem

**WebhooksController** expects `client_reference_id`:
```ruby
user_id = session['client_reference_id']
```

**StripeService** was NOT setting `client_reference_id`:
```ruby
session = Stripe::Checkout::Session.create(
  customer: customer.id,
  # client_reference_id was MISSING!
  mode: 'subscription',
  ...
)
```

### The Impact

When the user completes payment on Stripe:
1. Stripe webhook fires `checkout.session.completed`
2. Webhook handler looks for `client_reference_id` to find the user
3. `client_reference_id` is nil
4. User lookup fails
5. Subscription is NOT created in the database
6. Payment succeeds but user has no subscription!

## The Fix

Added `client_reference_id` to both subscription and credit pack checkout session creation:

```ruby
session = Stripe::Checkout::Session.create(
  customer: customer.id,
  client_reference_id: user.id.to_s,  # ← CRITICAL FIX
  mode: 'subscription',
  line_items: [{
    price: plan_config[:stripe_price_id],
    quantity: 1
  }],
  success_url: success_url,
  cancel_url: cancel_url,
  metadata: {
    user_id: user.id,
    plan_type: plan_type,
    role: user.role
  },
  ...
)
```

## Files Modified

1. `app/services/payment/stripe_service.rb`
   - Added `client_reference_id: user.id.to_s` to `create_subscription_checkout_session` 
   - Added `client_reference_id: user.id.to_s` to `create_credit_purchase_checkout_session`

2. `app/views/buyer/subscriptions/new.html.erb`
   - Added `data: { turbo: false }` to `button_to` to bypass Turbo for external redirects
   - **Critical**: Turbo was intercepting the redirect to Stripe, preventing the checkout from loading

## Second Critical Bug: Turbo Intercepting External Redirects

### The Problem

The subscription buttons use `button_to` which by default uses Turbo:
```erb
<%= button_to buyer_subscription_path, method: :post, params: { plan_type: "buyer_#{plan_key}" }, class: "..." do %>
```

When the controller redirects to Stripe's checkout URL:
1. User clicks "Choose Standard" button
2. Form submits via Turbo (AJAX-like request)
3. Controller creates checkout session and returns 302 redirect to https://checkout.stripe.com/...
4. **Turbo intercepts the redirect** and tries to handle it as an internal page transition
5. External URL doesn't load, user stays on same page
6. No subscription created

### The Fix

Disable Turbo on the checkout buttons:
```erb
<%= button_to buyer_subscription_path, 
    method: :post, 
    params: { plan_type: "buyer_#{plan_key}" }, 
    data: { turbo: false },  # ← CRITICAL FIX
    class: "..." do %>
```

Now:
1. User clicks button
2. Form submits as regular POST (not Turbo)
3. Controller redirects to Stripe
4. Browser follows redirect to Stripe checkout
5. ✅ User sees Stripe payment page

## Verification

The subscription flow should now work end-to-end:

1. ✅ User selects plan → Checkout session created
2. ✅ User redirected to Stripe → Payment completed
3. ✅ Webhook receives `checkout.session.completed`
4. ✅ Webhook finds user via `client_reference_id`
5. ✅ Subscription record created in database
6. ✅ User redirected back with active subscription

## Testing Recommendations

To test the complete flow:

1. Select a subscription plan
2. Complete test payment on Stripe (use test card)
3. Verify redirect back to success page
4. Check that subscription record exists in database
5. Verify user has access to subscription features

## Additional Notes

- The metadata also contains `user_id`, but Stripe's recommended practice is to use `client_reference_id` for user identification
- Both `client_reference_id` and metadata are now set for redundancy
- The webhook handler should now work reliably for both subscription and one-time payments
