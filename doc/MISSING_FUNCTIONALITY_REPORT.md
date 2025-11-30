# Missing Functionality Report - Complete Audit

**Generated:** Systematic analysis of Idéal Reprise Platform  
**Scope:** Brick 1 - Marketplace & Basic CRM  
**Method:** Route-by-route comparison against controllers and views

---

## Executive Summary

| Category | Total Issues | Critical | High | Medium | Low |
|----------|-------------|----------|------|--------|-----|
| Missing Controllers | 8 | 4 | 2 | 2 | 0 |
| Missing Controller Actions | 15 | 0 | 7 | 5 | 3 |
| Missing Views | 16 | 4 | 6 | 4 | 2 |
| **TOTAL** | **39** | **8** | **15** | **11** | **5** |

---

## 🔴 CRITICAL - Completely Missing (Controllers + Views)

### 1. ListingsController (Public)
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resources :listings, only: [:index, :show] do
  collection do
    get :search
  end
end
```

**Missing:**
- [ ] `app/controllers/listings_controller.rb`
- [ ] `app/views/listings/index.html.erb`
- [ ] `app/views/listings/show.html.erb`
- [ ] `app/views/listings/search.html.erb`

**Impact:** Freemium model broken - users cannot browse without authentication

---

### 2. DirectoryController (Public Partner Directory)
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resources :directory, only: [:index, :show], path: 'partners', as: :partners do
  collection do
    get :search
  end
end
```

**Missing:**
- [ ] `app/controllers/directory_controller.rb`
- [ ] `app/views/directory/index.html.erb`
- [ ] `app/views/directory/show.html.erb`
- [ ] `app/views/directory/search.html.erb`

**Impact:** Partners paying for directory visibility have no public exposure

---

### 3. CheckoutController (Payment)
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
namespace :checkout do
  get :select_plan
  get :payment_form, as: :payment
  post :process_payment
  get :success
  get :cancel
end
```

**Missing:**
- [ ] `app/controllers/checkout_controller.rb`
- [ ] `app/views/checkout/select_plan.html.erb`
- [ ] `app/views/checkout/payment_form.html.erb`
- [ ] `app/views/checkout/success.html.erb`
- [ ] `app/views/checkout/cancel.html.erb`

**Impact:** No payment processing - subscriptions/credits cannot be purchased

---

### 4. ErrorsController
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
get '404', to: 'errors#not_found'
get '403', to: 'errors#forbidden'
get '500', to: 'errors#server_error'
```

**Missing:**
- [ ] `app/controllers/errors_controller.rb`
- [ ] `app/views/errors/not_found.html.erb` (404)
- [ ] `app/views/errors/forbidden.html.erb` (403)
- [ ] `app/views/errors/server_error.html.erb` (500)

**Impact:** Poor error handling UX

---

### 5. Partner::ContactsController
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resources :contacts, only: [:index, :show]
```

**Missing:**
- [ ] `app/controllers/partner/contacts_controller.rb`
- [ ] `app/views/partner/contacts/index.html.erb`
- [ ] `app/views/partner/contacts/show.html.erb`

**Impact:** Partners cannot see who contacted them (referenced in dashboard)

---

### 6. Seller::NdasController
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resource :nda, only: [:show, :create]
```

**Missing:**
- [ ] `app/controllers/seller/ndas_controller.rb`
- [ ] `app/views/seller/ndas/show.html.erb`

**Impact:** Sellers cannot sign/manage their NDAs

---

### 7. Buyer::DocumentsController (nested under deals)
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resources :deals do
  resources :documents, except: [:index]
end
```

**Missing:**
- [ ] `app/controllers/buyer/documents_controller.rb`
- [ ] `app/views/buyer/documents/new.html.erb`
- [ ] `app/views/buyer/documents/show.html.erb`
- [ ] `app/views/buyer/documents/edit.html.erb`

**Impact:** Buyers cannot manage documents on deals (enrichment system affected)

---

### 8. Buyer::NotesController (nested under deals)
**Status:** ❌ COMPLETELY MISSING

**Routes Defined:**
```ruby
resources :deals do
  resources :notes, except: [:index]
end
```

**Missing:**
- [ ] `app/controllers/buyer/notes_controller.rb`
- [ ] `app/views/buyer/notes/new.html.erb`
- [ ] `app/views/buyer/notes/show.html.erb`
- [ ] `app/views/buyer/notes/edit.html.erb`

**Impact:** Buyers cannot add notes to deals

---

## 🟠 HIGH - Missing Controller Actions

### 9. Admin::UsersController - Missing Actions
**Controller exists:** ✅

**Missing Actions:**
- [ ] `change_role` - Route: `patch :change_role`
- [ ] `sellers` - Route: `get :sellers`
- [ ] `buyers` - Route: `get :buyers`
- [ ] `partners` - Route: `get :partners`
- [ ] `import` - Route: `get :import`
- [ ] `bulk_import` - Route: `post :bulk_import`

**Note:** These filtering/import routes exist but actions not implemented

---

### 10. Admin::PartnersController - Missing Actions
**Controller exists:** ✅

**Missing Actions:**
- [ ] `approve_form` - Route: `get :approve_form`
- [ ] `reject_form` - Route: `get :reject_form`

**Note:** `approve` and `reject` actions exist, but dedicated form views missing

---

### 11. Buyer::ListingsController - Missing Action
**Controller exists:** ✅

**Missing Action:**
- [ ] `search` - Route: `get :search`

**Note:** Index has filtering, but dedicated search action missing

---

### 12. Buyer::DealsController - Missing Action
**Controller exists:** ✅

**Missing Action:**
- [ ] `extend_timer` - Route: `post :extend_timer`

**Note:** Timer system exists but extension not implemented

---

### 13. Seller::ProfilesController - Missing Actions
**Controller exists:** ✅

**Missing Actions:**
- [ ] `new` - Not routed but may be needed
- [ ] `create` - Not routed but may be needed

**Note:** Profile is singular resource, `new`/`create` may not be needed if profile auto-created

---

### 14. Partner::ProfilesController - Missing Actions
**Controller exists:** ✅

**Missing Actions:**
- [ ] `new` - Profile creation flow
- [ ] `create` - Profile creation submission

**Note:** Same as seller - singular resource

---

### 15. NotificationsController - Missing Action
**Controller exists:** ✅

**Missing Action:**
- [ ] `mark_all_read` (duplicate route - both `mark_all_as_read` and `mark_all_read` defined)

**Note:** `mark_all_as_read` exists, redundant route definition

---

### 16. Seller::MessagesController - Route/Implementation Mismatch
**Controller exists:** ✅ (but only has `create`)

**Routes Defined:**
```ruby
resources :messages, only: [:index, :show, :new, :create]
```

**Missing Actions:**
- [ ] `index`
- [ ] `show`
- [ ] `new`

**Note:** Messages are handled via Conversations, these routes may be vestigial

---

### 17. Buyer::MessagesController - Route/Implementation Mismatch
**Controller exists:** ✅ (but only has `create`)

**Routes Defined:**
```ruby
resources :messages, only: [:index, :show, :new, :create]
```

**Missing Actions:**
- [ ] `index`
- [ ] `show`
- [ ] `new`

**Note:** Same as seller - messages via Conversations

---

## 🟡 MEDIUM - Missing Views Only

### 18. Pages Views
**Controller exists:** ✅

**Missing View:**
- [ ] `app/views/pages/support.html.erb`

---

### 19. Admin Users Views
**Controller exists:** ✅

**Missing View:**
- [ ] `app/views/admin/users/suspend_confirm.html.erb`

---

### 20. Admin Listings Views
**Controller exists:** ✅

**Missing Views:**
- [ ] `app/views/admin/listings/new.html.erb`
- [ ] `app/views/admin/listings/edit.html.erb`
- [ ] `app/views/admin/listings/validate_form.html.erb`
- [ ] `app/views/admin/listings/reject_form.html.erb`

---

### 21. Admin Partners Views
**Controller exists:** ✅

**Missing Views:**
- [ ] `app/views/admin/partners/approve_form.html.erb`
- [ ] `app/views/admin/partners/reject_form.html.erb`

---

### 22. Seller Buyers Views
**Controller exists:** ✅

**Missing View:**
- [ ] `app/views/seller/buyers/search.html.erb`

---

### 23. Seller Subscriptions Views
**Controller exists:** ✅

**Missing View:**
- [ ] `app/views/seller/subscriptions/upgrade.html.erb`

---

### 24. Buyer Listings Views
**Controller exists:** ✅

**Missing Views:**
- [ ] `app/views/buyer/listings/exclusive.html.erb`
- [ ] `app/views/buyer/listings/search.html.erb`

---

### 25. Partner Profiles Views
**Controller exists:** ✅

**Missing View:**
- [ ] `app/views/partner/profiles/preview.html.erb`

---

## 🟢 LOW - Minor Issues / Clarifications Needed

### 26. Route Redundancy - Notifications
Both routes defined:
```ruby
post :mark_all_as_read
patch :mark_all_read
```
**Action:** Remove one or consolidate

### 27. Standalone Messages vs Conversations
Routes define standalone `messages` resources for Seller/Buyer, but implementation uses Conversations.
**Action:** Remove vestigial routes or clarify design

### 28. Seller/Partner Profile new/create
Singular resources (`resource :profile`) typically don't need `new`/`create` if auto-created.
**Action:** Verify profile creation flow

---

## Implementation Priority Matrix

### Phase 1 - CRITICAL (Must fix before any launch)
| Item | Type | Est. Effort |
|------|------|-------------|
| ListingsController | Controller + Views | 4-6 hours |
| DirectoryController | Controller + Views | 4-6 hours |
| CheckoutController | Controller + Views + Stripe | 8-12 hours |
| ErrorsController | Controller + Views | 2-3 hours |

**Total Phase 1:** ~20-27 hours

### Phase 2 - HIGH (Required for full functionality)
| Item | Type | Est. Effort |
|------|------|-------------|
| Partner::ContactsController | Controller + Views | 3-4 hours |
| Seller::NdasController | Controller + Views | 2-3 hours |
| Buyer::DocumentsController | Controller + Views | 3-4 hours |
| Buyer::NotesController | Controller + Views | 2-3 hours |
| Admin missing views | Views only | 4-5 hours |
| Buyer listing views (exclusive/search) | Views only | 2-3 hours |

**Total Phase 2:** ~16-22 hours

### Phase 3 - MEDIUM (Polish/Complete)
| Item | Type | Est. Effort |
|------|------|-------------|
| Admin::UsersController actions | Actions only | 3-4 hours |
| Admin partner form views | Views only | 2 hours |
| Seller buyer search view | View only | 1 hour |
| Seller subscription upgrade view | View only | 1 hour |
| Buyer::DealsController#extend_timer | Action only | 2 hours |

**Total Phase 3:** ~9-10 hours

### Phase 4 - LOW (Cleanup)
| Item | Type | Est. Effort |
|------|------|-------------|
| Route cleanup | Config | 1 hour |
| Pages support view | View only | 1 hour |

**Total Phase 4:** ~2 hours

---

## Complete Checklist by Namespace

### Public (Non-authenticated)
- [ ] **ListingsController** - index, show, search
- [ ] **DirectoryController** - index, show, search
- [ ] **CheckoutController** - select_plan, payment_form, process_payment, success, cancel
- [ ] **ErrorsController** - not_found, forbidden, server_error
- [ ] PagesController#support (view only)

### Admin Namespace
- [x] DashboardController - ✅ Complete
- [x] LogsController - ✅ Complete
- [ ] UsersController - Missing: change_role, sellers, buyers, partners, import, bulk_import, suspend_confirm view
- [ ] ListingsController - Missing: new, edit, validate_form, reject_form views
- [ ] PartnersController - Missing: approve_form, reject_form actions & views
- [x] DealsController - ✅ Complete
- [x] LeadImportsController - ✅ Complete
- [x] EnrichmentsController - ✅ Complete
- [x] SettingsController - ✅ Complete
- [x] MessagesController - ✅ Complete
- [x] SurveysController - ✅ Complete

### Seller Namespace
- [x] DashboardController - ✅ Complete
- [x] ConversationsController - ✅ Complete
- [x] PartnersController - ✅ Complete
- [x] ListingsController - ✅ Complete
- [ ] BuyersController - Missing: search view
- [x] InterestsController - ✅ Complete
- [x] PushListingsController - ✅ Complete
- [x] EnrichmentsController - ✅ Complete
- [x] CreditsController - ✅ Complete
- [ ] SubscriptionsController - Missing: upgrade view
- [x] ProfilesController - ✅ Complete
- [x] SettingsController - ✅ Complete
- [x] AssistanceController - ✅ Complete
- [ ] MessagesController - Needs clarification (only create, rest via Conversations)
- [ ] **NdasController** - ❌ MISSING

### Buyer Namespace
- [x] DashboardController - ✅ Complete
- [x] ConversationsController - ✅ Complete
- [x] PartnersController - ✅ Complete
- [ ] ListingsController - Missing: search action, exclusive & search views
- [x] PipelinesController - ✅ Complete
- [ ] DealsController - Missing: extend_timer action
- [x] FavoritesController - ✅ Complete
- [x] EnrichmentsController - ✅ Complete
- [x] CreditsController - ✅ Complete
- [x] SubscriptionsController - ✅ Complete
- [x] ProfilesController - ✅ Complete
- [x] SettingsController - ✅ Complete
- [x] ServicesController - ✅ Complete
- [ ] MessagesController - Needs clarification (only create)
- [x] NdasController - ✅ Complete
- [x] ListingNdasController - ✅ Complete
- [ ] **DocumentsController** - ❌ MISSING
- [ ] **NotesController** - ❌ MISSING

### Partner Namespace
- [x] DashboardController - ✅ Complete
- [x] ConversationsController - ✅ Complete
- [ ] ProfilesController - Missing: new, create actions, preview view
- [x] SubscriptionsController - ✅ Complete
- [x] SettingsController - ✅ Complete
- [x] AnalyticsController - ✅ Complete
- [ ] **ContactsController** - ❌ MISSING
- [x] MessagesController - ✅ Complete (create only)

### Shared
- [ ] NotificationsController - Minor: redundant route
- [x] ConversationsController - ✅ Complete
- [x] MessagesController - ✅ Complete
- [x] SurveyResponsesController - ✅ Complete
- [x] WebhooksController - ✅ Complete

---

## Summary Statistics

**Working Routes/Controllers:**
- Admin: ~85% complete
- Seller: ~90% complete
- Buyer: ~85% complete
- Partner: ~80% complete
- Public: ~40% complete (critical gap!)
- Shared: ~95% complete

**Blocking Issues for Production:**
1. No public listing browse → No freemium funnel
2. No payment checkout → No revenue
3. No partner directory → Partners can't be found
4. Missing deal documents/notes → Incomplete CRM

**Recommended Order:**
1. CheckoutController (revenue blocker)
2. ListingsController (user acquisition)
3. DirectoryController (partner value)
4. ErrorsController (UX)
5. Partner::ContactsController (partner feature)
6. Buyer documents/notes (CRM completion)

---

*Report generated via systematic route-by-route audit*
