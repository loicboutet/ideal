# Payment System Implementation - Brick 1
## Idéal Reprise Platform

**Last Updated:** November 21, 2025 - 3:27 AM  
**Status:** Phases 1, 2 & 5 Complete ✅ - Subscriptions & Webhooks Operational  
**Next Phase:** Phase 3 - Credits System 🎯

---

## 🎯 CURRENT STATUS SUMMARY

### ✅ Completed Phases (3/10)
- **Phase 1:** Foundation & Setup - Database, models, Stripe configuration ✅
- **Phase 2:** Subscription System - All 3 role subscriptions working with Stripe Checkout ✅
- **Phase 5:** Webhooks & Event Handling - Real-time payment processing operational ✅

### 🎯 Next Priority: Phase 3 - Credits System (3 days)
**What's Needed:**
- Credit earning logic (deal releases, enrichments)
- Credit spending logic (listing pushes, partner access)
- Credit purchase flow with Stripe Checkout
- Credit management service

### 📊 Overall Progress: 30% Complete

---

## 🔄 SUBSCRIPTION USER FLOW

### Where Do Users Subscribe?

**Buyers:**
1. Navigate to `/buyer/subscription/new` (Plan Selection Page)
2. Choose from 4 paid tiers: Starter (€89/mo), Standard (€199/mo), Premium (€249/mo), Club (€1200/yr)
3. Click "Subscribe" button → Redirects to Stripe Checkout
4. Complete payment on Stripe's secure checkout page
5. Redirected back to `/buyer/subscription` (Success page)
6. Webhook activates subscription automatically in background
7. Can manage subscription at `/buyer/subscription` (view, upgrade, cancel)

**Sellers:**
1. Navigate to `/seller/subscription/new` (Premium Package page)
2. Click "Subscribe to Premium" → Redirects to Stripe Checkout
3. Complete payment and return to `/seller/subscription`
4. Unlock unlimited listings + 5 monthly pushes + partner access

**Partners:**
1. Navigate to `/partner/subscription/new` (Annual Directory page)
2. Click "Subscribe" → Redirects to Stripe Checkout
3. Complete payment and return to `/partner/subscription`
4. Profile appears in partner directory for 1 year

### Access Points in UI

**Navigation Links:**
- Buyer Dashboard: "Subscription" or "Upgrade Plan" button
- Seller Dashboard: "Go Premium" or "Subscription" link
- Partner Dashboard: "Subscription" or "Renew" link
- Settings page: "Billing & Subscription" section

**Upgrade Prompts:**
- Free users see upgrade CTAs when accessing premium features
- Limited feature access triggers "Upgrade to unlock" modals
- Email notifications about subscription benefits

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Phase 1: Foundation & Setup](#phase-1-foundation--setup-complete-)
3. [System Architecture](#system-architecture)
4. [Configuration Guide](#configuration-guide)
5. [Implementation Roadmap](#implementation-roadmap)
6. [Testing Guide](#testing-guide)

---

## OVERVIEW

The payment system integrates Stripe for handling:
- **Buyer Subscriptions**: 5 tiers (Free, Starter €89/mo, Standard €199/mo, Premium €249/mo, Club €1200/yr)
- **Seller Premium Package**: Broker subscription with unlimited listings
- **Partner Annual Subscription**: Directory listing fee
- **Credit System**: Multi-role credit purchases and management
- **Transaction Tracking**: Complete payment history and analytics

---

## PHASE 1: FOUNDATION & SETUP (COMPLETE ✅)

### ✅ Completed Tasks

#### 1. Gem Installation
- **Added**: `stripe ~> 12.0` to Gemfile
- **Installed**: Bundle install completed successfully

#### 2. Database Migrations

**Users Table Enhancement** (`20251120183657_add_payment_fields_to_users.rb`):
```ruby
- stripe_customer_id (string, unique index)
- credits_balance (integer, default: 0, not null)
```

**Subscriptions Table Update** (`20251120185750_add_cancel_at_period_end_to_subscriptions.rb`):
```ruby
- cancel_at_period_end (boolean)
```
*Note: Subscriptions table already existed with comprehensive fields*

**Payment Transactions Table** (`20251120190131_create_payment_transactions.rb`):
```ruby
- user_id (references users)
- amount (decimal 10,2, not null)
- currency (string, default: "EUR", not null)
- status (string, not null)
- stripe_payment_intent_id (string, indexed)
- transaction_type (string, not null, indexed)
- description (text)
- metadata (text)
- timestamps
```

**Credit Packs Table** (`20251120191859_create_credit_packs.rb`):
```ruby
- name (string, not null)
- credits_amount (integer, not null)
- price_cents (integer, not null)
- description (text)
- active (boolean, default: true, not null, indexed)
- timestamps
```

#### 3. Stripe Configuration

**Initializer** (`config/initializers/stripe.rb`):
- API key configuration from Rails credentials or ENV
- Webhook secret configuration
- API version locked to `2024-11-20.acacia`
- Logging for initialization confirmation

#### 4. Models

**PaymentTransaction** (`app/models/payment_transaction.rb`):
- Enums for transaction types and statuses
- Validations for all required fields
- Scopes: recent, successful, by_type, this_month
- Helper methods: amount_in_euros, successful?, failed?
- JSON serialization for metadata

**CreditPack** (`app/models/credit_pack.rb`):
- Validations for name, credits_amount, price_cents
- Scopes: active, ordered
- Helper methods: price_in_euros, price_formatted, credits_per_euro
- Seed method for default packs (10, 25, 50, 100 credits)

**Subscription** (existing):
- Already has comprehensive plan types
- Polymorphic profile association
- Status management
- Amount tracking

---

## SYSTEM ARCHITECTURE

### Database Schema

```
┌─────────────┐
│    Users    │
├─────────────┤
│ stripe_customer_id (unique)
│ credits_balance (default: 0)
└─────────────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────────┐  ┌────────────────────┐
│Subscriptions │  │PaymentTransactions │
├──────────────┤  ├────────────────────┤
│ plan_type    │  │ amount             │
│ status       │  │ currency           │
│ stripe_sub_id│  │ status             │
│ amount       │  │ transaction_type   │
│ period_start │  │ stripe_payment_id  │
│ period_end   │  │ description        │
│ cancel_at_   │  │ metadata           │
│   period_end │  └────────────────────┘
└──────────────┘

┌─────────────┐
│CreditPacks  │
├─────────────┤
│ name        │
│ credits_    │
│   amount    │
│ price_cents │
│ active      │
└─────────────┘
```

### Transaction Types

1. `subscription_payment` - Monthly/yearly subscription charges
2. `credit_purchase` - One-time credit pack purchases
3. `credit_award` - Credits given to users (releases, enrichments)
4. `credit_deduction` - Credits spent (push listings, partner access)
5. `refund` - Payment refunds

### Transaction Statuses

1. `pending` - Awaiting processing
2. `processing` - Payment in progress
3. `succeeded` - Completed successfully
4. `failed` - Payment failed
5. `canceled` - Payment canceled
6. `refunded` - Payment refunded

---

## CONFIGURATION GUIDE

### 1. Setting Up Stripe API Keys

**Option A: Rails Credentials (Recommended)**

```bash
# Edit credentials
EDITOR="code --wait" bin/rails credentials:edit

# Add Stripe keys
stripe:
  publishable_key: pk_test_xxxxx
  secret_key: sk_test_xxxxx
  webhook_secret: whsec_xxxxx
```

**Option B: Environment Variables**

```bash
# .env file (not committed to git)
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxx
STRIPE_SECRET_KEY=sk_test_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

### 2. Seeding Credit Packs

```bash
# In Rails console
rails console
CreditPack.seed_default_packs

# Or create a rake task
# lib/tasks/seed_credit_packs.rake
```

### 3. Testing Configuration

```bash
# Use Stripe test mode keys
# Test cards: https://stripe.com/docs/testing

# Success card
4242 4242 4242 4242

# Decline card  
4000 0000 0000 0002
```

---

## IMPLEMENTATION ROADMAP

### ✅ Phase 1: Foundation & Setup (COMPLETE)
**Duration:** Completed  
**Status:** Done

- [x] Install Stripe gem
- [x] Create database migrations
- [x] Set up Stripe initializer
- [x] Create base models
- [x] Document architecture

---

### ✅ Phase 2: Subscription System (COMPLETE)
**Duration:** Completed  
**Status:** Done

#### 2.1 Subscription Plans Configuration ✅
- [x] Define subscription plans in `config/initializers/subscription_plans.rb`
- [x] Configure BUYER_PLANS (Starter, Standard, Premium, Club)
- [x] Configure SELLER_PREMIUM_PLAN
- [x] Configure PARTNER_ANNUAL_PLAN
- [x] Create Stripe Products in Dashboard
- [x] Map Stripe Price IDs to environment variables

#### 2.2 Buyer Subscriptions ✅
- [x] Create `Buyer::SubscriptionsController`
  - `new` - Stripe Checkout session creation
  - `create` - Handle checkout
  - `cancel` - Cancel subscription
  - `success`/`cancel` - Redirect handlers
- [x] Implement Stripe Checkout integration with `Payment::StripeService`
- [x] Handle success/cancel redirects
- [x] Store client_reference_id for webhook matching

#### 2.3 Seller Subscriptions ✅
- [x] Create `Seller::SubscriptionsController`
- [x] Premium package subscription flow
- [x] Stripe Checkout integration
- [x] Success/cancel handling

#### 2.4 Partner Subscriptions ✅
- [x] Create `Partner::SubscriptionsController`
- [x] Annual subscription purchase flow
- [x] Stripe Checkout integration
- [x] Success/cancel redirects

#### 2.5 Service Layer ✅
- [x] Create `Payment::SubscriptionService` with methods:
  - `current_subscription(user)`
  - `has_active_subscription?(user)`
  - `create_subscription`
  - `cancel_subscription`
  - `activate_subscription` (for webhooks)
  - `subscription_summary(user)`
- [x] Create `Payment::StripeService` for Checkout sessions
- [x] Add Subscription model helper methods
- [x] Price ID to plan type mapping

#### 2.6 Configuration ✅
- [x] Stripe API keys in `.env` file
- [x] All 6 Stripe Price IDs configured
- [x] dotenv-rails gem installed
- [x] Routes configured for all 3 roles

---

### 📦 Phase 3: Credits System (3 days)
**Priority:** HIGH

#### 3.1 Credit Management Service
- [ ] Create `Payment::CreditService`
  - `add_credits(user, amount, reason, reference)`
  - `deduct_credits(user, amount, reason, reference)`
  - `check_balance(user, amount)`
  - `transaction_history(user)`
- [ ] Add credit transaction logging
- [ ] Implement atomic credit operations

#### 3.2 Credit Earning Logic
- [ ] Update Deal release to award +1 credit
- [ ] Award +1 credit per document category on release
- [ ] Integrate with existing enrichment workflow
- [ ] Add credit award notifications

#### 3.3 Credit Spending Logic
- [ ] Update ListingPush to deduct 1 credit
- [ ] Add partner directory access cost (5 credits after 6 months)
- [ ] Add credit checks before premium actions
- [ ] Show insufficient credits errors
- [ ] Redirect to purchase page

#### 3.4 Credit Purchase Flow
- [ ] Create `Payment::CreditsController`
  - `index` - Show available packs
  - `checkout` - Create Stripe session for pack
- [ ] Build credit purchase page with pack cards
- [ ] Implement Stripe Checkout for one-time payments
- [ ] Award credits on successful payment
- [ ] Send purchase confirmation email

---

### 💳 Phase 4: Payment Processing (2 days)
**Priority:** HIGH

#### 4.1 Stripe Checkout Integration
- [ ] Create checkout session helper
- [ ] Build success page with order confirmation
- [ ] Build cancel page with retry option
- [ ] Add loading states during redirect

#### 4.2 Payment Intent Handling
- [ ] Create payment intents for one-time purchases
- [ ] Handle payment confirmation
- [ ] Error handling and user feedback
- [ ] Retry logic for failed payments

#### 4.3 Customer Management
- [ ] Create Stripe customer on first purchase
- [ ] Store customer ID on user record
- [ ] Sync customer data with Stripe
- [ ] Implement customer portal access

---

### ✅ Phase 5: Webhooks & Event Handling (COMPLETE)
**Duration:** Completed  
**Status:** Done

#### 5.1 Webhook Endpoint Setup ✅
- [x] Create `WebhooksController` at root level
- [x] Verify Stripe webhook signatures
- [x] Route events to specific handler methods
- [x] Comprehensive error handling and logging
- [x] Public route `/webhooks/stripe` (no auth required)
- [x] CSRF protection skipped for webhook endpoint

#### 5.2 Subscription Events ✅
- [x] `customer.subscription.created` - Initial subscription setup
- [x] `customer.subscription.updated` - Plan changes, status updates
- [x] `customer.subscription.deleted` - Handle cancellations
- [x] Update local subscription records with Stripe data
- [x] Sync current_period_start and current_period_end

#### 5.3 Payment Events ✅
- [x] `checkout.session.completed` - Activate subscription & log transaction
- [x] Handle both subscription and one-time payments
- [x] Award credits for credit pack purchases
- [x] Create PaymentTransaction records
- [x] Link payments to users via client_reference_id

#### 5.4 Invoice Events ✅
- [x] `invoice.payment_succeeded` - Log successful renewals
- [x] `invoice.payment_failed` - Mark subscription as past_due
- [x] Update subscription status based on invoice events
- [x] Create payment transaction records

#### 5.5 Local Development Setup ✅
- [x] Stripe CLI installed and configured
- [x] Webhook forwarding to `localhost:3000/webhooks/stripe`
- [x] Webhook secret obtained and added to `.env`
- [x] Testing with `stripe listen` command
- [x] Real-time webhook event monitoring

#### 5.6 Integration ✅
- [x] `activate_subscription` method in SubscriptionService
- [x] Price ID to plan type mapping
- [x] Automatic customer ID storage on user record
- [x] Find or create subscription logic
- [x] Metadata storage in JSON format

---

### 👨‍💼 Phase 6: Admin Features (1-2 days)
**Priority:** MEDIUM

#### 6.1 Revenue Dashboard
- [ ] Create `Admin::RevenueController`
- [ ] Monthly revenue calculation
- [ ] Revenue by category charts
- [ ] Export revenue data to CSV

#### 6.2 Transaction Management
- [ ] View all transactions with filtering
- [ ] Manual credit adjustments (admin only)
- [ ] Refund management interface
- [ ] Transaction search and export

#### 6.3 Subscription Management
- [ ] View all active subscriptions
- [ ] Cancel/pause subscriptions (admin)
- [ ] Subscription health metrics
- [ ] Churn analysis

---

### 🎨 Phase 7: User Interfaces (3-4 days)
**Priority:** HIGH

#### 7.1 Buyer Interfaces
- [ ] Subscription selection page with comparison table
- [ ] Current subscription display in dashboard
- [ ] Upgrade/downgrade flows
- [ ] Cancellation confirmation modal
- [ ] Credits balance widget
- [ ] Credit purchase page
- [ ] Transaction history page
- [ ] Payment method management

#### 7.2 Seller Interfaces
- [ ] Premium package purchase page
- [ ] Credits balance in dashboard
- [ ] Credit purchase page
- [ ] Push listing credit check
- [ ] Partner access credit check
- [ ] Transaction history

#### 7.3 Partner Interfaces
- [ ] Subscription status display
- [ ] Annual renewal page
- [ ] Payment history

#### 7.4 Shared Components
- [ ] Payment success modal/page
- [ ] Payment failure handling
- [ ] Loading states during Stripe redirect
- [ ] Credit balance widget (reusable)
- [ ] Subscription badge component

---

### 🔒 Phase 8: Access Control & Feature Gating (1-2 days)
**Priority:** HIGH

#### 8.1 Subscription Checks
- [ ] Implement plan-based feature access
- [ ] Create helper methods:
  - `current_user.subscription_active?`
  - `current_user.has_plan?(:premium)`
  - `current_user.can_access_feature?(:advanced_search)`
- [ ] Add before_action filters for paid features
- [ ] Show upgrade prompts for free users

#### 8.2 Credit-Based Actions
- [ ] Before filters for credit-required actions
- [ ] Insufficient credits error pages
- [ ] Purchase prompts when credits needed
- [ ] Credit balance checks in views

#### 8.3 Premium Package Checks (Sellers)
- [ ] Unlimited listings validation
- [ ] Monthly push quota tracking
- [ ] Partner directory access validation
- [ ] Premium feature highlighting

---

### 🧪 Phase 9: Testing & QA (2-3 days)
**Priority:** CRITICAL

#### 9.1 Test Mode Testing
- [ ] Test all subscription flows with Stripe test cards
- [ ] Test credit purchases
- [ ] Test webhook handling
- [ ] Test failure scenarios
- [ ] Verify email notifications

#### 9.2 Integration Testing
- [ ] Subscription → feature access
- [ ] Credit purchase → balance update
- [ ] Credit spending → balance deduction
- [ ] Webhook events → database updates
- [ ] End-to-end user journeys

#### 9.3 Edge Cases
- [ ] Concurrent transactions
- [ ] Failed payments
- [ ] Webhook retries
- [ ] Subscription cancellations
- [ ] Refunds
- [ ] Race conditions

---

### 🔐 Phase 10: Security & Compliance (1 day)
**Priority:** CRITICAL

- [ ] Secure API key storage verification
- [ ] Webhook signature verification
- [ ] PCI compliance check (handled by Stripe)
- [ ] GDPR considerations for payment data
- [ ] Audit trail for financial transactions
- [ ] Rate limiting for payment endpoints
- [ ] SSL/TLS verification

---

## PRICING STRUCTURE

### Buyer Plans

| Plan | Price | Features |
|------|-------|----------|
| **Free** | €0 | Browse only, limited access |
| **Starter** | €89/month | Basic features, limited reservations |
| **Standard** | €199/month | Full features, more reservations |
| **Premium** | €249/month | All features, unlimited reservations |
| **Club** | €1200/year | All features + 1h coaching |

### Seller Plans

| Plan | Price | Features |
|------|-------|----------|
| **Free** | €0 | Basic listing features |
| **Premium (Broker)** | TBD | Unlimited listings, priority support, 5 pushes/month, partner directory access (first 6 months free) |

### Partner Plans

| Plan | Price | Features |
|------|-------|----------|
| **Annual Directory** | TBD | Listed in partner directory for 1 year |

### Credit Packs

| Pack | Credits | Price | €/Credit |
|------|---------|-------|----------|
| Starter | 10 | €9.90 | €0.99 |
| Popular | 25 | €19.90 | €0.80 |
| Pro | 50 | €29.90 | €0.60 |
| Premium | 100 | €49.90 | €0.50 |

---

## TESTING GUIDE

### Stripe Test Cards

```
# Always succeeds
4242 4242 4242 4242

# Always declined
4000 0000 0000 0002

# Requires authentication (3D Secure)
4000 0025 0000 3155

# Insufficient funds
4000 0000 0000 9995
```

### Test Scenarios

1. **Subscription Creation**
   - Select plan → Checkout → Success
   - Verify subscription in database
   - Verify Stripe subscription created
   - Check webhook received

2. **Credit Purchase**
   - Select pack → Checkout → Success
   - Verify credits added to balance
   - Verify transaction logged
   - Check webhook received

3. **Failed Payment**
   - Use decline card
   - Verify error handling
   - Verify no credits/subscription added
   - Verify user notified

4. **Subscription Cancellation**
   - Cancel subscription
   - Verify cancel_at_period_end set
   - Verify access until period end
   - Verify no renewal

---

## NEXT STEPS

### Immediate Actions Required

1. **Set up Stripe Account**
   - Create Stripe account at stripe.com
   - Obtain test API keys
   - Configure webhook endpoint
   - Add keys to Rails credentials

2. **Create Stripe Products**
   - Create products in Stripe Dashboard for each plan
   - Create prices for each product
   - Note Product/Price IDs for configuration

3. **Begin Phase 2**
   - Start with buyer subscription implementation
   - Create subscription controllers
   - Build UI for plan selection

### Developer Notes

- All prices stored in cents (integer)
- Currency is EUR (European market)
- Webhook signature verification is mandatory
- Use Stripe test mode until go-live
- Monitor Stripe Dashboard for events
- Set up proper error tracking (e.g., Sentry)

---

## RESOURCES

- [Stripe Ruby SDK Documentation](https://stripe.com/docs/api?lang=ruby)
- [Stripe Testing Guide](https://stripe.com/docs/testing)
- [Stripe Webhook Guide](https://stripe.com/docs/webhooks)
- [Stripe Checkout Documentation](https://stripe.com/docs/payments/checkout)
- [Stripe Subscriptions Guide](https://stripe.com/docs/billing/subscriptions/overview)

---

**Document Owner:** Development Team  
**Next Review:** After Phase 2 completion  
**Related Documents:**
- `doc/specifications.md`
- `BRICK1_REMAINING_FEATURES_SUMMARY.md`
