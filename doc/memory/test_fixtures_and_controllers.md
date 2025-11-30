# Test Fixtures and Controller Tests Documentation

## Overview

This document describes the test fixtures and controller tests created for the Idéal Reprise project.

## Test Files Created

| Test File | Controller | Tests | Assertions |
|-----------|-----------|-------|------------|
| `test/controllers/buyer/dashboard_controller_test.rb` | Buyer::DashboardController | 27 | ~113 |
| `test/controllers/seller/dashboard_controller_test.rb` | Seller::DashboardController | 14 | ~23 |
| `test/controllers/seller/interests_controller_test.rb` | Seller::InterestsController | 23 | ~61 |
| `test/controllers/seller/push_listings_controller_test.rb` | Seller::PushListingsController | 20 | ~88 |
| `test/controllers/admin/dashboard_controller_test.rb` | Admin::DashboardController | 33 | ~70 |
| `test/controllers/admin/enrichments_controller_test.rb` | Admin::EnrichmentsController | 38 | ~98 |

**Total: 155 tests, 453 assertions**

## Fixtures Created/Updated

### Users (`test/fixtures/users.yml`)
- `admin` - Admin user
- `seller` - Primary seller user
- `seller_two` - Secondary seller user
- `buyer` - Primary buyer user with standard subscription
- `buyer_two` - Premium buyer
- `buyer_three` - Free buyer
- `partner` - Partner user (lawyer)
- `inactive_buyer` - Suspended buyer (for auth tests)

### Buyer Profiles (`test/fixtures/buyer_profiles.yml`)
- `buyer_profile` - Standard subscription, 25 credits
- `buyer_profile_two` - Premium subscription, 50 credits
- `buyer_profile_three` - Free, 5 credits
- `inactive_buyer_profile` - Inactive subscription

### Seller Profiles (`test/fixtures/seller_profiles.yml`)
- `seller_profile` - 10 credits
- `seller_profile_two` - Premium access, 50 credits
- `seller_profile_premium` - Broker with 100 credits

### Partner Profiles (`test/fixtures/partner_profiles.yml`)
- `partner_profile` - Approved lawyer partner

### Listings (`test/fixtures/listings.yml`)
- `listing_one` - Approved/published with 45 views
- `listing_zero_views` - Approved/published with 0 views
- `listing_zero_views_two` - Another 0 views listing
- `listing_pending` - Pending validation
- `listing_pending_two` - Another pending
- `listing_two` - Owned by seller_two, 120 views

### Deals (`test/fixtures/deals.yml`)
- `deal_active` - Active deal with future timer
- `deal_expiring_soon` - Timer expires in 12 hours
- `deal_expired` - Timer expired 5 days ago
- `deal_expired_two` - Timer expired 2 days ago
- `deal_loi` - In LOI stage
- `deal_favorited` - Favorited only (not reserved)
- `deal_negotiation` - In negotiation
- `deal_signed` - Completed deal

### Favorites (`test/fixtures/favorites.yml`)
- Various favorites linking buyers to listings
- Recent favorites (within 7 days)
- Older favorites (more than 7 days)

### Enrichments (`test/fixtures/enrichments.yml`)
- `enrichment_pending` - 3 pending enrichments
- `enrichment_approved` - 3 approved enrichments
- `enrichment_rejected` - 2 rejected enrichments

### Conversations and Messages
- `conversations.yml` - Test conversations between users
- `conversation_participants.yml` - User participation with last_read_at
- `messages.yml` - Read and unread messages

### Other Fixtures
- `credit_packs.yml` - Credit packs for purchase
- `payment_transactions.yml` - Sample payment transactions

## Test Categories

### Authentication Tests
- ✅ Authenticated users can access their dashboards
- ✅ Unauthenticated users are redirected to login
- ✅ Wrong role users are redirected to root
- ✅ Inactive users are blocked

### Buyer Dashboard Tests
- ✅ Stats calculation (total deals, active reservations, favorites, credits, unread messages)
- ✅ New favorites count in last 7 days
- ✅ Shortest timer calculation
- ✅ Available listings count
- ✅ Subscription info (name, end date, max reservations)
- ✅ Pipeline stages structure and counts
- ✅ Expiring soon deals identification

### Seller Dashboard Tests
- ✅ Analytics summary loading
- ✅ New interests this week calculation
- ✅ Unread messages count
- ✅ Views growth calculation

### Seller Interests Tests
- ✅ List interested buyers with correct structure
- ✅ Stats calculation (total, this week, active negotiations)
- ✅ Buyer profile details display
- ✅ Favorites and deals filtering by seller's listings

### Seller Push Listings Tests
- ✅ Credit balance display
- ✅ Interested buyers listing
- ✅ Active listings selection
- ✅ Successful push with credit deduction
- ✅ Failure cases (insufficient credits, no buyers, wrong listing)
- ✅ Edge cases (invalid buyer IDs)

### Admin Dashboard Operations Tests
- ✅ Zero views listings count
- ✅ Pending validations count
- ✅ Expired timers count
- ✅ CRM status distribution
- ✅ Listings per buyer ratio
- ✅ Drilldown pages (zero_views, expired_timers)

### Admin Enrichments Tests
- ✅ List and filter enrichments
- ✅ Stats calculation
- ✅ Approval workflow with credit awarding
- ✅ Rejection workflow with reason
- ✅ Edge cases (empty states, nonexistent records)

## Bug Fixes Made During Testing

The following issues were discovered and fixed during test development:

1. **Buyer Dashboard Controller** (`app/controllers/buyer/dashboard_controller.rb`)
   - Fixed: `conversation_participants.participant` → `conversation_participants.user_id`
   - Fixed: `subscription_ends_at` → `subscription_expires_at`

2. **Seller Dashboard Controller** (`app/controllers/seller/dashboard_controller.rb`)
   - Fixed: Same conversation participant query issue

3. **Seller Dashboard View** (`app/views/seller/dashboard/index.html.erb`)
   - Fixed: `listing.active?` → `listing.published?`

4. **Seller Interests Views**
   - Fixed: `profile_completion_percentage` → `completeness_score`
   - Fixed: `target_regions` → `target_locations`
   - Fixed: `budget_min/budget_max` → `target_revenue_min/target_revenue_max`

5. **Seller Push Listings View**
   - Fixed: Same attribute name issues

6. **Admin Dashboard Controller** (`app/controllers/admin/dashboard_controller.rb`)
   - Fixed: `partner.company_name` → `partner.user.company_name`

7. **Admin Enrichments Controller** (`app/controllers/admin/enrichments_controller.rb`)
   - Fixed: `status` → `validation_status`
   - Fixed: `reviewed_at` → `validated_at`
   - Fixed: `reviewed_by_id` → `validated_by_id`

8. **Admin Enrichments Views**
   - Fixed: Same attribute naming issues

## Running the Tests

```bash
# Run all new controller tests
bin/rails test test/controllers/buyer/dashboard_controller_test.rb \
  test/controllers/seller/dashboard_controller_test.rb \
  test/controllers/seller/interests_controller_test.rb \
  test/controllers/seller/push_listings_controller_test.rb \
  test/controllers/admin/dashboard_controller_test.rb \
  test/controllers/admin/enrichments_controller_test.rb \
  --verbose

# Run single test file
bin/rails test test/controllers/buyer/dashboard_controller_test.rb --verbose

# Run with limited output
bin/rails test test/controllers/buyer/dashboard_controller_test.rb 2>&1 | tail -30
```

## Dependencies

Added to Gemfile:
```ruby
group :test do
  gem "rails-controller-testing"
end
```

This gem provides `assigns` helper for accessing controller instance variables in tests.

## Test Helper Configuration

`test/test_helper.rb` includes:
- `fixtures :all` - Load all fixtures
- Devise integration test helpers
- Custom `sign_in_as` helper method
