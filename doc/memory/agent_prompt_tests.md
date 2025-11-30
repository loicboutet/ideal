# Agent Prompt: Write Tests for Missing Functionality Implementation

## Context

You are a Senior Rails Developer writing tests for newly implemented controllers and views in the Idéal Reprise platform. The following controllers were just implemented to fill critical missing functionality:

1. **ListingsController** (Public) - Freemium listing browse
2. **DirectoryController** (Public Partner Directory)
3. **CheckoutController** (Payment/Subscription)
4. **ErrorsController** (Custom error pages)

## Your Task

Write comprehensive tests for all four controllers. Tests should cover:
- Controller actions (happy path and edge cases)
- Authentication requirements (or lack thereof for public routes)
- View rendering
- Redirects and flash messages
- Filter/search functionality
- Pagination

## Technical Requirements

- **Framework:** Rails 8 with Minitest (default Rails testing)
- **Fixtures:** Use existing fixtures or create minimal test data
- **Language:** Test descriptions in English, but verify French UI strings where relevant
- **Performance:** Keep tests fast - mock external services, limit database operations

## File Locations

```
test/controllers/
├── listings_controller_test.rb      # NEW - Create this
├── directory_controller_test.rb     # NEW - Create this
├── checkout_controller_test.rb      # NEW - Create this
└── errors_controller_test.rb        # NEW - Create this
```

## Implementation Details

### 1. ListingsController Tests (`test/controllers/listings_controller_test.rb`)

```ruby
# frozen_string_literal: true

require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  # Setup: Create test listings with proper attributes
  
  # === INDEX ACTION ===
  
  test "should get index without authentication" do
    # Public route - no auth required
    get listings_url
    assert_response :success
  end
  
  test "index should display published and approved listings only" do
    # Create listings with different statuses
    # Verify only status: :published, validation_status: :approved appear
  end
  
  test "index should filter by sector" do
    get listings_url, params: { sector: "commerce" }
    assert_response :success
    # Verify filtering works
  end
  
  test "index should filter by max_price" do
    get listings_url, params: { max_price: 500000 }
    assert_response :success
  end
  
  test "index should filter by location" do
    get listings_url, params: { location: "Paris" }
    assert_response :success
  end
  
  test "index should sort by price ascending" do
    get listings_url, params: { sort: "price_asc" }
    assert_response :success
  end
  
  test "index should paginate results" do
    # Create more than 12 listings
    get listings_url, params: { page: 2 }
    assert_response :success
  end
  
  test "index should show stats in response" do
    get listings_url
    assert_select ".bg-blue-50" # Stats card
  end
  
  # === SHOW ACTION ===
  
  test "should get show for published approved listing" do
    # Create a valid listing
    listing = listings(:published_approved) # or create inline
    get listing_url(listing)
    assert_response :success
  end
  
  test "show should redirect for draft listing" do
    listing = listings(:draft)
    get listing_url(listing)
    assert_redirected_to listings_url
  end
  
  test "show should redirect for pending listing" do
    listing = listings(:pending)
    get listing_url(listing)
    assert_redirected_to listings_url
  end
  
  test "show should increment view count" do
    listing = listings(:published_approved)
    assert_difference -> { listing.reload.views_count }, 1 do
      get listing_url(listing)
    end
  end
  
  test "show should display paywall for unauthenticated users" do
    get listing_url(listings(:published_approved))
    assert_select ".blur-sm" # Blurred content
    assert_select "a[href=?]", new_user_registration_path
  end
  
  # === SEARCH ACTION ===
  
  test "should get search without authentication" do
    get search_listings_url
    assert_response :success
  end
  
  test "search should filter by keyword" do
    get search_listings_url, params: { q: "boulangerie" }
    assert_response :success
  end
  
  test "search should filter by multiple criteria" do
    get search_listings_url, params: { 
      q: "commerce", 
      sector: "commerce",
      min_price: 100000,
      max_price: 500000,
      location: "Paris"
    }
    assert_response :success
  end
  
  test "search should display active filters" do
    get search_listings_url, params: { sector: "commerce", location: "Paris" }
    assert_select ".bg-blue-100" # Active filter badges
  end
  
  test "search should show no results message when empty" do
    get search_listings_url, params: { q: "xyznonexistent123" }
    assert_response :success
    # Check for empty state
  end
end
```

### 2. DirectoryController Tests (`test/controllers/directory_controller_test.rb`)

```ruby
# frozen_string_literal: true

require "test_helper"

class DirectoryControllerTest < ActionDispatch::IntegrationTest
  # Setup: Create test partner profiles with active subscriptions
  
  # === INDEX ACTION ===
  
  test "should get index without authentication" do
    get partners_url
    assert_response :success
  end
  
  test "index should only show approved partners with active subscription" do
    # Create partners with different statuses
    # Verify filtering
  end
  
  test "index should filter by partner type" do
    get partners_url, params: { type: "lawyer" }
    assert_response :success
  end
  
  test "index should filter by location" do
    get partners_url, params: { location: "Paris" }
    assert_response :success
  end
  
  test "index should filter by coverage area" do
    get partners_url, params: { coverage: "nationwide" }
    assert_response :success
  end
  
  test "index should filter premium only" do
    get partners_url, params: { premium: "1" }
    assert_response :success
  end
  
  test "index should sort by rating" do
    get partners_url, params: { sort: "rating" }
    assert_response :success
  end
  
  test "index should paginate results" do
    get partners_url, params: { page: 2 }
    assert_response :success
  end
  
  # === SHOW ACTION ===
  
  test "should get show for approved partner with active subscription" do
    partner = partner_profiles(:approved_active)
    get partners_url(partner)
    assert_response :success
  end
  
  test "show should redirect for unapproved partner" do
    partner = partner_profiles(:pending)
    get partners_url(partner)
    assert_redirected_to partners_url
  end
  
  test "show should redirect for expired subscription" do
    partner = partner_profiles(:expired_subscription)
    get partners_url(partner)
    assert_redirected_to partners_url
  end
  
  test "show should increment view count" do
    partner = partner_profiles(:approved_active)
    assert_difference -> { partner.reload.views_count }, 1 do
      get partners_url(partner)
    end
  end
  
  test "show should hide contact info for unauthenticated users" do
    get partners_url(partner_profiles(:approved_active))
    assert_select ".bg-gray-50" # Protected contact section
  end
  
  test "show should display contact info for authenticated users" do
    sign_in users(:buyer)
    get partners_url(partner_profiles(:approved_active))
    # Verify contact info is visible
  end
  
  # === SEARCH ACTION ===
  
  test "should get search without authentication" do
    get search_partners_url
    assert_response :success
  end
  
  test "search should filter by keyword" do
    get search_partners_url, params: { q: "avocat" }
    assert_response :success
  end
  
  test "search should filter by multiple criteria" do
    get search_partners_url, params: {
      q: "transmission",
      type: "lawyer",
      location: "Paris",
      coverage: "region"
    }
    assert_response :success
  end
end
```

### 3. CheckoutController Tests (`test/controllers/checkout_controller_test.rb`)

```ruby
# frozen_string_literal: true

require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  # === AUTHENTICATION ===
  
  test "select_plan should require authentication" do
    get checkout_select_plan_url
    assert_redirected_to new_user_session_path
  end
  
  test "payment_form should require authentication" do
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_redirected_to new_user_session_path
  end
  
  test "process_payment should require authentication" do
    post checkout_process_payment_url, params: { plan: "buyer_pro" }
    assert_redirected_to new_user_session_path
  end
  
  # === SELECT PLAN ACTION ===
  
  test "should get select_plan for authenticated buyer" do
    sign_in users(:buyer)
    get checkout_select_plan_url
    assert_response :success
    assert_select "h1", /Choisissez votre abonnement/
  end
  
  test "select_plan should show buyer plans for buyer role" do
    sign_in users(:buyer)
    get checkout_select_plan_url
    assert_select "h3", /Essentiel/
    assert_select "h3", /Professionnel/
    assert_select "h3", /Club/
  end
  
  test "select_plan should show seller plans for seller role" do
    sign_in users(:seller)
    get checkout_select_plan_url
    assert_select "h3", /Gratuit/
    assert_select "h3", /Premium/
  end
  
  test "select_plan should show partner plans for partner role" do
    sign_in users(:partner)
    get checkout_select_plan_url
    assert_select "h3", /Annuaire Partenaire/
  end
  
  test "select_plan should show credit packs for buyer" do
    sign_in users(:buyer)
    get checkout_select_plan_url
    assert_select "h2", /Acheter des crédits/
  end
  
  # === PAYMENT FORM ACTION ===
  
  test "should get payment_form with valid plan" do
    sign_in users(:buyer)
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_response :success
    assert_select "h2", /Informations de paiement/
  end
  
  test "payment_form should redirect with invalid plan" do
    sign_in users(:buyer)
    get checkout_payment_url, params: { plan: "invalid_plan" }
    assert_redirected_to checkout_select_plan_url
    assert_equal "Plan sélectionné invalide.", flash[:alert]
  end
  
  test "payment_form should display order summary" do
    sign_in users(:buyer)
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_select "h2", /Récapitulatif/
    assert_select ".text-2xl", /199/ # Price
  end
  
  test "payment_form should pre-fill user info" do
    user = users(:buyer)
    sign_in user
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_select "input[value=?]", user.email
  end
  
  # === PROCESS PAYMENT ACTION ===
  
  test "process_payment should redirect to success on valid payment" do
    sign_in users(:buyer)
    post checkout_process_payment_url, params: { 
      plan: "buyer_pro",
      billing: { first_name: "Test", last_name: "User", email: "test@example.com" },
      card: { number: "4242424242424242", expiry: "12/25", cvc: "123" },
      accept_terms: "1"
    }
    assert_redirected_to checkout_success_url(plan: "buyer_pro")
  end
  
  test "process_payment should redirect to cancel on invalid plan" do
    sign_in users(:buyer)
    post checkout_process_payment_url, params: { plan: "invalid" }
    assert_redirected_to checkout_select_plan_url
  end
  
  # === SUCCESS ACTION ===
  
  test "should get success" do
    sign_in users(:buyer)
    get checkout_success_url, params: { plan: "buyer_pro" }
    assert_response :success
    assert_select "h1", /Paiement réussi/
  end
  
  test "success should display plan details" do
    sign_in users(:buyer)
    get checkout_success_url, params: { plan: "buyer_pro" }
    assert_select "h3", /Professionnel/
  end
  
  test "success should show role-specific next steps" do
    sign_in users(:buyer)
    get checkout_success_url, params: { plan: "buyer_pro" }
    assert_select "li", /Parcourez les annonces/
  end
  
  # === CANCEL ACTION ===
  
  test "should get cancel" do
    sign_in users(:buyer)
    get checkout_cancel_url
    assert_response :success
    assert_select "h1", /Paiement non finalisé/
  end
  
  test "cancel should show reason-specific message" do
    sign_in users(:buyer)
    get checkout_cancel_url, params: { reason: "declined" }
    assert_response :success
    assert_select "p", /carte a été refusée/
  end
end
```

### 4. ErrorsController Tests (`test/controllers/errors_controller_test.rb`)

```ruby
# frozen_string_literal: true

require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  # === 404 NOT FOUND ===
  
  test "should get not_found" do
    get "/404"
    assert_response :not_found
  end
  
  test "not_found should render proper view" do
    get "/404"
    assert_select "h1", /Page introuvable/
    assert_select ".text-9xl", "404"
  end
  
  test "not_found should have navigation links" do
    get "/404"
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", listings_path
  end
  
  test "not_found should respond to json" do
    get "/404", headers: { "Accept" => "application/json" }
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not Found", json["error"]
    assert_equal 404, json["status"]
  end
  
  # === 403 FORBIDDEN ===
  
  test "should get forbidden" do
    get "/403"
    assert_response :forbidden
  end
  
  test "forbidden should render proper view" do
    get "/403"
    assert_select "h1", /Accès refusé/
    assert_select ".text-9xl", "403"
  end
  
  test "forbidden should show login link for unauthenticated users" do
    get "/403"
    assert_select "a[href=?]", new_user_session_path
  end
  
  test "forbidden should respond to json" do
    get "/403", headers: { "Accept" => "application/json" }
    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Forbidden", json["error"]
  end
  
  # === 500 SERVER ERROR ===
  
  test "should get server_error" do
    get "/500"
    assert_response :internal_server_error
  end
  
  test "server_error should render proper view" do
    get "/500"
    assert_select "h1", /Erreur serveur/
    assert_select ".text-9xl", "500"
  end
  
  test "server_error should have retry button" do
    get "/500"
    assert_select "button", /Réessayer/
  end
  
  test "server_error should respond to json" do
    get "/500", headers: { "Accept" => "application/json" }
    assert_response :internal_server_error
    json = JSON.parse(response.body)
    assert_equal "Internal Server Error", json["error"]
  end
end
```

## Fixtures Required

Create or update fixtures in `test/fixtures/`:

### `test/fixtures/listings.yml`

```yaml
published_approved:
  title: "Boutique de test"
  industry_sector: commerce
  status: published
  validation_status: approved
  asking_price: 250000
  annual_revenue: 400000
  location_city: "Paris"
  location_department: "75"
  seller_profile: seller_one
  published_at: <%= 3.days.ago %>
  views_count: 10

draft:
  title: "Brouillon"
  industry_sector: services
  status: draft
  validation_status: pending
  seller_profile: seller_one

pending:
  title: "En attente"
  industry_sector: services
  status: published
  validation_status: pending
  seller_profile: seller_one
```

### `test/fixtures/partner_profiles.yml`

```yaml
approved_active:
  user: partner_user
  partner_type: lawyer
  validation_status: approved
  directory_subscription_expires_at: <%= 1.year.from_now %>
  company_name: "Cabinet Test"
  city: "Paris"
  department: "75"
  views_count: 5

pending:
  user: partner_user_two
  partner_type: accountant
  validation_status: pending
  directory_subscription_expires_at: <%= 1.year.from_now %>

expired_subscription:
  user: partner_user_three
  partner_type: consultant
  validation_status: approved
  directory_subscription_expires_at: <%= 1.month.ago %>
```

### `test/fixtures/users.yml`

```yaml
buyer:
  email: "buyer@test.com"
  role: buyer
  # ... other required fields

seller:
  email: "seller@test.com"
  role: seller

partner:
  email: "partner@test.com"
  role: partner

admin:
  email: "admin@test.com"
  role: admin
```

## Running Tests

```bash
# Run all new tests
bin/rails test test/controllers/listings_controller_test.rb test/controllers/directory_controller_test.rb test/controllers/checkout_controller_test.rb test/controllers/errors_controller_test.rb

# Run with verbose output
bin/rails test test/controllers/listings_controller_test.rb -v

# Run specific test
bin/rails test test/controllers/listings_controller_test.rb:15
```

## Important Notes

1. **Authentication Helper:** Use `sign_in` from Devise test helpers
2. **Database Cleaning:** Tests should be isolated - use transactions or database cleaner
3. **Fixtures vs Factories:** Use fixtures for simplicity, but factories (FactoryBot) if already in project
4. **Mocking:** Mock external services (Stripe) in checkout tests
5. **Assertions:** Use both `assert_response` and `assert_select` for comprehensive coverage

## Success Criteria

- [ ] All tests pass
- [ ] Each controller action has at least one test
- [ ] Edge cases are covered (invalid params, unauthorized access)
- [ ] Response formats tested (HTML and JSON where applicable)
- [ ] Flash messages verified
- [ ] Redirects verified
- [ ] View content verified with `assert_select`

## Estimated Time

- ListingsController tests: 1-2 hours
- DirectoryController tests: 1-2 hours
- CheckoutController tests: 2-3 hours
- ErrorsController tests: 30 minutes
- Fixtures setup: 30 minutes

**Total: 5-8 hours**
