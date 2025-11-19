# Credits & Premium Implementation Status Report

**Date:** November 19, 2025  
**Analysis Scope:** Credits & Premium features as specified in specifications.md

---

## Executive Summary

**Implementation Level: ~30% Complete**

The Credits & Premium system has a solid foundation (database schema, basic models) but lacks the business logic and user-facing features required for full functionality. The system can track and deduct credits but cannot award them automatically, sell credit packs, or process premium subscriptions.

---

## Specification Requirements

According to `doc/specifications.md`, the Credits & Premium system for sellers should include:

### For All Sellers:
1. ✅ **Earn credits for premium actions** - PARTIALLY IMPLEMENTED
2. ❌ **Buy credit packs** - NOT IMPLEMENTED

### For Broker Premium Package:
3. ❌ **Unlimited listings** - NOT IMPLEMENTED
4. ❌ **Priority support** - NOT IMPLEMENTED
5. ❌ **Partner directory access** - NOT IMPLEMENTED
6. ❌ **Push listings to 5 buyers/month** - NOT IMPLEMENTED

---

## What IS Implemented ✅

### 1. Database Foundation (Complete)

**seller_profiles table:**
```ruby
t.integer "credits", default: 0, null: false
t.boolean "premium_access", default: false, null: false
t.boolean "is_broker", default: false, null: false
t.string "stripe_customer_id"
```

**buyer_profiles table:**
```ruby
t.integer "credits", default: 0, null: false
t.integer "subscription_plan", default: 0, null: false
t.integer "subscription_status", default: 0, null: false
t.datetime "subscription_expires_at"
t.string "stripe_customer_id"
```

**subscriptions table:**
- Full tracking with Stripe integration fields
- Polymorphic association (works for any profile type)

**deals table:**
```ruby
t.integer "total_credits_earned", default: 0, null: false
```

**enrichments table:**
```ruby
t.integer "credits_awarded", default: 0, null: false
```

**Status:** ✅ Database schema is complete and ready

---

### 2. Basic Credit Model Logic

**app/models/seller_profile.rb:**
```ruby
def add_credits(amount)
  increment!(:credits, amount)
end

def deduct_credits(amount)
  return false if credits < amount
  decrement!(:credits, amount)
  true
end
```

**Validations:**
- Credit balance cannot be negative
- User can only have one seller profile

**Status:** ✅ Basic credit operations work

---

### 3. Credit Usage - Push to Buyer

**app/controllers/seller/listings_controller.rb:**
```ruby
def push_to_buyer
  # Check if seller has enough credits
  unless seller_profile.credits >= 1
    redirect_to seller_buyer_path(buyer_profile),
                alert: "Vous n'avez pas assez de crédits..."
    return
  end
  
  # Deduct credit
  seller_profile.deduct_credits(1)
  # ... create listing push
end
```

**Status:** ✅ Credits are properly deducted when pushing listings

---

### 4. Routes Configuration

**config/routes.rb includes:**
```ruby
namespace :seller do
  resources :credits, only: [:index]
  resource :subscription, only: [:show, :update, :destroy]
end

namespace :buyer do
  resources :credits, only: [:index] do
    collection do
      get :purchase_options
    end
  end
  resource :subscription
end
```

**Status:** ✅ Routes exist but controllers are missing

---

### 5. UI Display

**app/views/seller/buyers/show.html.erb:**
```erb
Crédits disponibles: 
<strong class="text-gray-900">
  <%= current_user.seller_profile.credits || 0 %>
</strong>
```

**Admin user management:**
- Can set credits manually
- Can toggle premium_access flag

**Status:** ✅ Credit balance is displayed, admin can manage credits

---

### 6. Mockup Views

**Mockup pages exist for:**
- `mockups/buyer/credits#index` - Credit purchase page
- `mockups/buyer/subscription#show` - Subscription management
- `mockups/seller/subscription#show` - Seller subscription
- `mockups/checkout/*` - Payment flows

**Status:** ✅ UI designs are ready but not connected to real functionality

---

## What is MISSING/NOT Implemented ❌

### 1. Credit Earning System ❌

**Problem:** No automatic credit awards

**Missing Logic:**
- ❌ Award credits when buyer releases a deal (+1 credit)
- ❌ Award credits per document when buyer enriches listing
- ❌ Award credits when seller validates enrichment
- ❌ No credit transaction history

**Current State:**
- Database fields exist (`total_credits_earned`, `credits_awarded`)
- No code to actually award credits
- No tracking of credit sources (earned vs purchased)

**Impact:** Users cannot earn credits, defeating the gamification aspect

---

### 2. Credit Pack Purchase ❌

**Problem:** No way to buy credits

**Missing Components:**

**Controllers:**
- ❌ `app/controllers/seller/credit_purchases_controller.rb`
- ❌ `app/controllers/buyer/credit_purchases_controller.rb`

**Views:**
- ❌ Credit pack selection page
- ❌ Checkout integration
- ❌ Success confirmation page
- ❌ Transaction history page

**Configuration:**
- ❌ No credit pack definitions (pricing, quantities)
- ❌ No Stripe product IDs

**Impact:** Users have no way to purchase credits (major revenue blocker)

---

### 3. Premium Broker Package ❌

#### 3.1 Unlimited Listings ❌

**Current State:**
- `premium_access` flag exists in database
- No enforcement of listing limits

**Missing:**
```ruby
# app/models/seller_profile.rb
def can_create_listing?
  return true if premium_access
  listings.where(status: :active).count < 1 # Free limit
end
```

**Impact:** Free and premium sellers have same limits

---

#### 3.2 Priority Support ❌

**Current State:**
- No support ticket system exists
- No support controllers or views

**Missing:**
- ❌ Support ticket model
- ❌ Support ticket controller
- ❌ Priority queue logic
- ❌ Support UI

**Impact:** No way to provide priority support

---

#### 3.3 Partner Directory Access ❌

**Current State:**
- Partner profiles exist
- Partner directory exists
- No access control based on seller status

**Missing:**
```ruby
# app/controllers/seller/partners_controller.rb
before_action :check_partner_access

def check_partner_access
  unless current_user.seller_profile.premium_access || 
         current_user.seller_profile.credits >= 5
    redirect_to upgrade_path, alert: "Accès réservé aux membres premium"
  end
end
```

**Missing Database Field:**
- `partner_access_until` (for "free first 6 months" promotion)

**Impact:** No monetization of partner directory access

---

#### 3.4 Push Listings (5 buyers/month) ❌

**Current State:**
- Push functionality exists
- Deducts 1 credit per push
- No monthly allowance for premium users

**Missing Logic:**
```ruby
# app/models/seller_profile.rb
def can_push_to_buyer?
  return true if credits >= 1 # Can always use credits
  
  if premium_access
    monthly_pushes_used < 5 # Premium monthly allowance
  else
    false
  end
end

def monthly_pushes_used
  listing_pushes.where('created_at >= ?', 1.month.ago).count
end
```

**Missing Database Fields:**
- `monthly_push_count` (reset each month)
- `last_push_reset_at` (tracking reset date)

**Impact:** Premium feature not differentiated from free tier

---

### 4. Stripe Payment Integration ❌

**Problem:** Stripe setup exists but no payment processing

**What Exists:**
- `stripe_customer_id` fields in database
- Stripe mentioned in routes

**What's Missing:**

**Configuration:**
- ❌ `config/initializers/stripe.rb`
- ❌ Stripe API keys in credentials
- ❌ Product/Price IDs configuration

**Controllers:**
- ❌ `app/controllers/payments/credits_controller.rb`
- ❌ `app/controllers/payments/subscriptions_controller.rb`
- ❌ `app/controllers/webhooks/stripe_controller.rb`

**Webhook Handlers:**
- ❌ `checkout.session.completed`
- ❌ `customer.subscription.created`
- ❌ `customer.subscription.updated`
- ❌ `customer.subscription.deleted`
- ❌ `invoice.payment_succeeded`
- ❌ `invoice.payment_failed`

**Views:**
- ❌ Stripe checkout integration
- ❌ Payment success/failure pages

**Impact:** No payment processing = no revenue

---

### 5. Subscription Management UI ❌

**Problem:** No production subscription pages

**Missing Pages:**
- ❌ Premium feature comparison page
- ❌ Subscription signup flow
- ❌ Subscription management (upgrade/downgrade)
- ❌ Cancellation flow
- ❌ Billing history

**Current State:**
- Only mockup views exist
- No controller logic

**Impact:** Users cannot subscribe to premium

---

### 6. Credit Transaction History ❌

**Problem:** No audit trail for credits

**Missing:**
- ❌ `credit_transactions` table
- ❌ Transaction recording logic
- ❌ Transaction history view

**Should Track:**
- Credit purchases (amount, price paid, date)
- Credit usage (action, amount, date)
- Credit awards (source, amount, date)

**Impact:** No transparency, debugging difficult

---

### 7. Admin Management Tools ❌

**Partial Implementation:**
- ✅ Admin can manually set credits
- ✅ Admin can toggle premium_access

**Missing:**
- ❌ Subscription overview dashboard
- ❌ Revenue reporting (MRR, churn)
- ❌ Credit usage analytics
- ❌ Refund handling
- ❌ Manual subscription cancellation
- ❌ Premium user list

**Impact:** Limited admin control and visibility

---

## Database Migrations Needed

### 1. Seller Profile Enhancements
```ruby
add_column :seller_profiles, :monthly_push_count, :integer, default: 0
add_column :seller_profiles, :last_push_reset_at, :datetime
add_column :seller_profiles, :partner_access_until, :datetime
add_column :seller_profiles, :subscription_tier, :integer, default: 0
```

### 2. Credit Transactions Table
```ruby
create_table :credit_transactions do |t|
  t.references :user, null: false, foreign_key: true
  t.string :profile_type, null: false # SellerProfile or BuyerProfile
  t.bigint :profile_id, null: false
  t.integer :transaction_type, null: false # purchase, earn, spend
  t.integer :amount, null: false
  t.integer :balance_after, null: false
  t.string :source # what generated this transaction
  t.text :description
  t.string :stripe_transaction_id
  t.timestamps
end

add_index :credit_transactions, [:profile_type, :profile_id]
add_index :credit_transactions, :transaction_type
```

### 3. Support Tickets Table (for Priority Support)
```ruby
create_table :support_tickets do |t|
  t.references :user, null: false, foreign_key: true
  t.string :subject, null: false
  t.text :description, null: false
  t.integer :status, default: 0, null: false # open, in_progress, resolved
  t.integer :priority, default: 0, null: false # normal, high (premium)
  t.integer :assigned_to_id
  t.timestamps
end
```

---

## Configuration Files Needed

### 1. Credit Packs (`config/initializers/credit_packs.rb`)
```ruby
CREDIT_PACKS = {
  small: {
    credits: 10,
    price: 49.00,
    currency: 'EUR',
    stripe_price_id: ENV['STRIPE_CREDIT_PACK_SMALL']
  },
  medium: {
    credits: 25,
    price: 99.00,
    currency: 'EUR',
    stripe_price_id: ENV['STRIPE_CREDIT_PACK_MEDIUM'],
    popular: true
  },
  large: {
    credits: 50,
    price: 179.00,
    currency: 'EUR',
    stripe_price_id: ENV['STRIPE_CREDIT_PACK_LARGE']
  }
}
```

### 2. Subscription Plans (`config/initializers/subscription_plans.rb`)
```ruby
SELLER_SUBSCRIPTION_PLANS = {
  free: {
    name: 'Gratuit',
    price: 0,
    features: {
      max_listings: 1,
      monthly_pushes: 0,
      partner_directory: false,
      support_priority: :standard
    }
  },
  broker_premium: {
    name: 'Premium Courtier',
    price: 299.00,
    currency: 'EUR',
    interval: 'month',
    stripe_price_id: ENV['STRIPE_SELLER_PREMIUM_MONTHLY'],
    features: {
      max_listings: 999, # unlimited
      monthly_pushes: 5,
      partner_directory: true,
      support_priority: :high
    }
  }
}
```

### 3. Stripe Configuration (`config/initializers/stripe.rb`)
```ruby
Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: Rails.application.credentials.dig(:stripe, :secret_key),
  signing_secret: Rails.application.credentials.dig(:stripe, :webhook_secret)
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
```

---

## Implementation Priority Recommendations

### 🔴 Critical (Revenue Blockers)
1. **Stripe Integration** - Required for any payments
2. **Credit Pack Purchase** - Primary monetization
3. **Premium Subscription Flow** - Secondary monetization

### 🟡 High Priority (Core Features)
4. **Credit Earning Logic** - User engagement
5. **Premium Feature Enforcement** - Value proposition
6. **Transaction History** - Transparency & debugging

### 🟢 Medium Priority (Enhancement)
7. **Partner Directory Access Control** - Additional revenue
8. **Monthly Push Allowance** - Premium differentiation
9. **Admin Management Tools** - Operational efficiency

### ⚪ Low Priority (Future)
10. **Priority Support System** - Can launch without
11. **Advanced Analytics** - Nice to have

---

## Estimated Implementation Effort

| Phase | Components | Effort | Dependencies |
|-------|-----------|---------|--------------|
| Stripe Setup | Config, credentials | 2 hours | None |
| Credit Purchases | Controllers, views, Stripe Checkout | 8 hours | Stripe Setup |
| Webhooks | Handler, processing logic | 6 hours | Stripe Setup |
| Credit Earning | Model logic, background jobs | 4 hours | None |
| Premium Features | Limits, access control | 6 hours | None |
| Subscription Flow | Controllers, views, Stripe | 10 hours | Stripe Setup |
| Transaction History | Model, migration, views | 4 hours | None |
| Admin Tools | Dashboard, reports | 6 hours | All above |
| Testing | Unit, integration, manual | 8 hours | All above |

**Total Estimated Effort:** 54 hours (~7 working days)

---

## Risk Assessment

### Technical Risks
- **Stripe Integration:** Webhook reliability, testing in production
- **Payment Security:** PCI compliance (mitigated by Stripe Checkout)
- **Race Conditions:** Credit deductions during concurrent requests

### Business Risks
- **Pricing:** No market validation of credit pack prices
- **Feature Mix:** Premium package may need adjustment
- **Conversion:** No A/B testing framework for pricing

### Mitigation Strategies
- Use Stripe test mode extensively
- Implement idempotency keys for payments
- Add transaction locking for credit operations
- Start with conservative pricing, iterate based on data

---

## Testing Requirements

### Unit Tests
- [ ] Credit earning calculations
- [ ] Credit deduction with insufficient balance
- [ ] Premium limit enforcement
- [ ] Monthly push counter reset

### Integration Tests
- [ ] Credit purchase flow (test mode)
- [ ] Subscription creation/update/cancel
- [ ] Webhook processing
- [ ] Credit transaction recording

### Manual Testing Checklist
- [ ] Test credit purchase with real card
- [ ] Test subscription lifecycle
- [ ] Test webhook delivery
- [ ] Test 3DS authentication
- [ ] Test failed payment handling
- [ ] Test refund processing

---

## Next Steps

### Immediate Actions
1. ✅ Document current state (this file)
2. Create Stripe test account
3. Generate API keys and add to credentials
4. Create Stripe products and prices
5. Begin Phase 4 (Stripe Integration)

### Week 1 Focus
- Complete Stripe integration
- Implement credit pack purchase
- Set up webhook handlers
- Test purchase flow end-to-end

### Week 2 Focus
- Implement credit earning logic
- Add premium feature enforcement
- Create subscription flow
- Build admin management tools

---

## Conclusion

The Credits & Premium system has excellent foundations but requires significant development to be production-ready. The highest priority is completing the payment integration to enable revenue generation. With focused effort, the system can be fully functional within 2 weeks.

**Status: 30% Complete**  
**Blocker: No payment processing**  
**Recommended Next Step: Implement Stripe Integration (Phase 4)**

---

*Report generated: November 19, 2025*  
*Based on analysis of: specifications.md, database schema, models, controllers, views, and routes*
