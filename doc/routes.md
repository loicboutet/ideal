# Routes Documentation - Idéal Reprise

## Overview

All routes are **RESTful** and follow **KISS principles**. Routes are organized by user type (role) for clear user journeys. All mockup routes are prefixed with `/mockups` and handled by mockup controllers.

---

## Public Routes (No Authentication Required)

### Marketing & Information

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups` | GET | mockups#index | mockups/index | Landing page / homepage |
| `/mockups/about` | GET | mockups#about | mockups/about | About Idéal Reprise |
| `/mockups/how_it_works` | GET | mockups#how_it_works | mockups/how_it_works | How the platform works |
| `/mockups/pricing` | GET | mockups#pricing | mockups/pricing | Pricing plans for all user types |
| `/mockups/contact` | GET | mockups#contact | mockups/contact | Contact form |

### Authentication (Devise-style mockups)

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/login` | GET | mockups/auth#login | mockups/auth/login | Login page (all user types) |
| `/mockups/register` | GET | mockups/auth#register | mockups/auth/register | Registration choice page |
| `/mockups/register/seller` | GET | mockups/auth#register_seller | mockups/auth/register_seller | Seller registration form |
| `/mockups/register/buyer` | GET | mockups/auth#register_buyer | mockups/auth/register_buyer | Buyer registration form |
| `/mockups/register/partner` | GET | mockups/auth#register_partner | mockups/auth/register_partner | Partner registration form |
| `/mockups/forgot_password` | GET | mockups/auth#forgot_password | mockups/auth/forgot_password | Password reset request |
| `/mockups/reset_password` | GET | mockups/auth#reset_password | mockups/auth/reset_password | Password reset form |

### Browse Listings (Freemium Access)

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/listings` | GET | mockups/listings#index | mockups/listings/index | Browse all listings (limited info) |
| `/mockups/listings/:id` | GET | mockups/listings#show | mockups/listings/show | Single listing view (teaser with paywall) |
| `/mockups/listings/search` | GET | mockups/listings#search | mockups/listings/search | Search/filter listings |

---

## Admin Routes

**Scope:** `/mockups/admin`

All admin routes require authentication and admin role.

### Dashboard & Analytics

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin` | GET | mockups/admin#dashboard | mockups/admin/dashboard | Main admin dashboard with metrics |
| `/mockups/admin/analytics` | GET | mockups/admin#analytics | mockups/admin/analytics | Detailed analytics & reports |

### User Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/users` | GET | mockups/admin/users#index | mockups/admin/users/index | List all users (all roles) |
| `/mockups/admin/users/:id` | GET | mockups/admin/users#show | mockups/admin/users/show | User detail view |
| `/mockups/admin/users/new` | GET | mockups/admin/users#new | mockups/admin/users/new | Create new user form |
| `/mockups/admin/users/:id/edit` | GET | mockups/admin/users#edit | mockups/admin/users/edit | Edit user form |
| `/mockups/admin/users/:id/suspend` | GET | mockups/admin/users#suspend_confirm | mockups/admin/users/suspend_confirm | Confirm suspend user |

### Listing Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/listings` | GET | mockups/admin/listings#index | mockups/admin/listings/index | All listings (all statuses) |
| `/mockups/admin/listings/pending` | GET | mockups/admin/listings#pending | mockups/admin/listings/pending | Pending validation queue |
| `/mockups/admin/listings/:id` | GET | mockups/admin/listings#show | mockups/admin/listings/show | Listing detail for validation |
| `/mockups/admin/listings/:id/validate` | GET | mockups/admin/listings#validate_form | mockups/admin/listings/validate_form | Approve listing form |
| `/mockups/admin/listings/:id/reject` | GET | mockups/admin/listings#reject_form | mockups/admin/listings/reject_form | Reject listing form |

### Partner Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/partners` | GET | mockups/admin/partners#index | mockups/admin/partners/index | All partners (all statuses) |
| `/mockups/admin/partners/pending` | GET | mockups/admin/partners#pending | mockups/admin/partners/pending | Pending partner validation |
| `/mockups/admin/partners/:id` | GET | mockups/admin/partners#show | mockups/admin/partners/show | Partner detail |
| `/mockups/admin/partners/:id/approve` | GET | mockups/admin/partners#approve_form | mockups/admin/partners/approve_form | Approve partner form |
| `/mockups/admin/partners/:id/reject` | GET | mockups/admin/partners#reject_form | mockups/admin/partners/reject_form | Reject partner form |

### Deal Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/deals` | GET | mockups/admin/deals#index | mockups/admin/deals/index | All deals across platform |
| `/mockups/admin/deals/:id` | GET | mockups/admin/deals#show | mockups/admin/deals/show | Deal detail view |
| `/mockups/admin/deals/:id/assign` | GET | mockups/admin/deals#assign_form | mockups/admin/deals/assign_form | Assign deal exclusively to buyer |

### Import Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/imports` | GET | mockups/admin/imports#index | mockups/admin/imports/index | Import history list |
| `/mockups/admin/imports/new` | GET | mockups/admin/imports#new | mockups/admin/imports/new | Upload Excel file form |
| `/mockups/admin/imports/:id` | GET | mockups/admin/imports#show | mockups/admin/imports/show | Import results/errors |

### Enrichment Validation

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/admin/enrichments` | GET | mockups/admin/enrichments#index | mockups/admin/enrichments/index | Pending enrichments to validate |
| `/mockups/admin/enrichments/:id` | GET | mockups/admin/enrichments#show | mockups/admin/enrichments/show | Enrichment detail |
| `/mockups/admin/enrichments/:id/approve` | GET | mockups/admin/enrichments#approve_form | mockups/admin/enrichments/approve_form | Approve & award credits |

---

## Seller Routes (Cédants)

**Scope:** `/mockups/seller`

All seller routes require authentication and seller role.

### Dashboard

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/seller` | GET | mockups/seller#dashboard | mockups/seller/dashboard | Seller dashboard overview |

### My Listings

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/seller/listings` | GET | mockups/seller/listings#index | mockups/seller/listings/index | My listings (all statuses) |
| `/mockups/seller/listings/new` | GET | mockups/seller/listings#new | mockups/seller/listings/new | Create new listing form |
| `/mockups/seller/listings/:id` | GET | mockups/seller/listings#show | mockups/seller/listings/show | My listing detail |
| `/mockups/seller/listings/:id/edit` | GET | mockups/seller/listings#edit | mockups/seller/listings/edit | Edit listing form |
| `/mockups/seller/listings/:id/documents` | GET | mockups/seller/listings#documents | mockups/seller/listings/documents | Manage listing documents |
| `/mockups/seller/listings/:id/documents/new` | GET | mockups/seller/listings#new_document | mockups/seller/listings/new_document | Upload new document |

### Interest & Contacts

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/seller/interests` | GET | mockups/seller/interests#index | mockups/seller/interests/index | Buyers interested in my listings |
| `/mockups/seller/interests/:id` | GET | mockups/seller/interests#show | mockups/seller/interests/show | Interest detail |

### Profile & Settings

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/seller/profile` | GET | mockups/seller/profile#show | mockups/seller/profile/show | My profile view |
| `/mockups/seller/profile/edit` | GET | mockups/seller/profile#edit | mockups/seller/profile/edit | Edit profile form |
| `/mockups/seller/settings` | GET | mockups/seller/settings#show | mockups/seller/settings/show | Account settings |
| `/mockups/seller/subscription` | GET | mockups/seller/subscription#show | mockups/seller/subscription/show | Premium access/upgrade |

### NDA

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/seller/nda` | GET | mockups/seller/nda#show | mockups/seller/nda/show | View/sign platform NDA |

---

## Buyer Routes (Repreneurs)

**Scope:** `/mockups/buyer`

All buyer routes require authentication and buyer role.

### Dashboard

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer` | GET | mockups/buyer#dashboard | mockups/buyer/dashboard | Buyer dashboard / CRM overview |

### Browse & Search

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/listings` | GET | mockups/buyer/listings#index | mockups/buyer/listings/index | Browse all available listings |
| `/mockups/buyer/listings/search` | GET | mockups/buyer/listings#search | mockups/buyer/listings/search | Advanced search/filters |
| `/mockups/buyer/listings/:id` | GET | mockups/buyer/listings#show | mockups/buyer/listings/show | Full listing detail (after NDA) |

### CRM / Pipeline Management

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/pipeline` | GET | mockups/buyer/pipeline#index | mockups/buyer/pipeline/index | Drag & drop CRM pipeline |
| `/mockups/buyer/deals` | GET | mockups/buyer/deals#index | mockups/buyer/deals/index | My deals (list view) |
| `/mockups/buyer/deals/:id` | GET | mockups/buyer/deals#show | mockups/buyer/deals/show | Deal detail with notes |
| `/mockups/buyer/deals/:id/edit` | GET | mockups/buyer/deals#edit | mockups/buyer/deals/edit | Edit deal notes/status |
| `/mockups/buyer/deals/new` | GET | mockups/buyer/deals#new | mockups/buyer/deals/new | Add listing to pipeline (from listing page) |

### Favorites

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/favorites` | GET | mockups/buyer/favorites#index | mockups/buyer/favorites/index | My favorited listings |

### Reservations

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/reservations` | GET | mockups/buyer/reservations#index | mockups/buyer/reservations/index | My active reservations with timers |
| `/mockups/buyer/reservations/:id` | GET | mockups/buyer/reservations#show | mockups/buyer/reservations/show | Reservation detail |
| `/mockups/buyer/reservations/:id/release` | GET | mockups/buyer/reservations#release_confirm | mockups/buyer/reservations/release_confirm | Release reservation confirmation |

### Enrichments

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/enrichments` | GET | mockups/buyer/enrichments#index | mockups/buyer/enrichments/index | My enrichment submissions |
| `/mockups/buyer/enrichments/new` | GET | mockups/buyer/enrichments#new | mockups/buyer/enrichments/new | Submit enrichment form |
| `/mockups/buyer/enrichments/:id` | GET | mockups/buyer/enrichments#show | mockups/buyer/enrichments/show | Enrichment detail/status |

### Credits & Subscription

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/credits` | GET | mockups/buyer/credits#index | mockups/buyer/credits/index | Credits balance & history |
| `/mockups/buyer/subscription` | GET | mockups/buyer/subscription#show | mockups/buyer/subscription/show | My subscription details |
| `/mockups/buyer/subscription/upgrade` | GET | mockups/buyer/subscription#upgrade | mockups/buyer/subscription/upgrade | Upgrade plan |
| `/mockups/buyer/subscription/cancel` | GET | mockups/buyer/subscription#cancel_confirm | mockups/buyer/subscription/cancel_confirm | Cancel subscription confirm |

### Profile & Settings

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/profile` | GET | mockups/buyer/profile#show | mockups/buyer/profile/show | My profile view |
| `/mockups/buyer/profile/edit` | GET | mockups/buyer/profile#edit | mockups/buyer/profile/edit | Edit profile form |
| `/mockups/buyer/settings` | GET | mockups/buyer/settings#show | mockups/buyer/settings/show | Account settings |

### NDA

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/buyer/nda` | GET | mockups/buyer/nda#show | mockups/buyer/nda/show | View/sign platform NDA |
| `/mockups/buyer/nda/listing/:id` | GET | mockups/buyer/nda#listing_nda | mockups/buyer/nda/listing_nda | Sign listing-specific NDA |

---

## Partner Routes

**Scope:** `/mockups/partner`

All partner routes require authentication and partner role.

### Dashboard

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/partner` | GET | mockups/partner#dashboard | mockups/partner/dashboard | Partner dashboard |

### Profile & Directory

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/partner/profile` | GET | mockups/partner/profile#show | mockups/partner/profile/show | My directory profile (public view) |
| `/mockups/partner/profile/edit` | GET | mockups/partner/profile#edit | mockups/partner/profile/edit | Edit directory profile |
| `/mockups/partner/profile/preview` | GET | mockups/partner/profile#preview | mockups/partner/profile/preview | Preview public profile |

### Subscription

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/partner/subscription` | GET | mockups/partner/subscription#show | mockups/partner/subscription/show | Directory subscription status |
| `/mockups/partner/subscription/renew` | GET | mockups/partner/subscription#renew | mockups/partner/subscription/renew | Renew directory subscription |

### Settings

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/partner/settings` | GET | mockups/partner/settings#show | mockups/partner/settings/show | Account settings |

---

## Partner Directory (Public Browse)

**Scope:** `/mockups/directory`

Public-facing partner directory (no auth required for browsing).

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/directory` | GET | mockups/directory#index | mockups/directory/index | Browse partner directory |
| `/mockups/directory/:id` | GET | mockups/directory#show | mockups/directory/show | Partner profile detail |
| `/mockups/directory/search` | GET | mockups/directory#search | mockups/directory/search | Search partners by type/location |

---

## Shared/Common Routes

### Notifications

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/notifications` | GET | mockups/notifications#index | mockups/notifications/index | All notifications |
| `/mockups/notifications/:id` | GET | mockups/notifications#show | mockups/notifications/show | Single notification |

### Legal Pages

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/terms` | GET | mockups/legal#terms | mockups/legal/terms | Terms & conditions |
| `/mockups/privacy` | GET | mockups/legal#privacy | mockups/legal/privacy | Privacy policy |
| `/mockups/nda_template` | GET | mockups/legal#nda_template | mockups/legal/nda_template | NDA template text |

---

## Payment/Checkout Routes

**Scope:** `/mockups/checkout`

Payment flows (Stripe integration mockups).

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/checkout/select_plan` | GET | mockups/checkout#select_plan | mockups/checkout/select_plan | Choose subscription plan |
| `/mockups/checkout/payment` | GET | mockups/checkout#payment_form | mockups/checkout/payment_form | Payment form (Stripe) |
| `/mockups/checkout/success` | GET | mockups/checkout#success | mockups/checkout/success | Payment success page |
| `/mockups/checkout/cancel` | GET | mockups/checkout#cancel | mockups/checkout/cancel | Payment cancelled page |

---

## Error Pages

| Route | HTTP Method | Controller#Action | View | Description |
|-------|-------------|-------------------|------|-------------|
| `/mockups/404` | GET | mockups/errors#not_found | mockups/errors/404 | Page not found |
| `/mockups/403` | GET | mockups/errors#forbidden | mockups/errors/403 | Access forbidden |
| `/mockups/500` | GET | mockups/errors#server_error | mockups/errors/500 | Server error |

---

## Route Structure Summary

### Total Routes: ~110 routes

**By Category:**
- Public: ~10 routes
- Admin: ~30 routes
- Seller: ~15 routes
- Buyer: ~30 routes
- Partner: ~10 routes
- Directory: ~5 routes
- Shared: ~10 routes

### Controller Structure

All controllers should inherit from `MockupsController`:

```ruby
# Base controller for all mockups
class MockupsController < ApplicationController
  layout 'mockup'
  skip_before_action :authenticate_user! # No real authentication needed
end

# Namespaced controllers
class Mockups::AdminController < MockupsController
  layout 'mockup_admin'
end

class Mockups::SellerController < MockupsController
  layout 'mockup_user'
end

class Mockups::BuyerController < MockupsController
  layout 'mockup_user'
end

class Mockups::PartnerController < MockupsController
  layout 'mockup_user'
end
```

---

## View Expectations

### Each Route Should Display:

1. **Navigation**
   - Appropriate for user role
   - Active state on current page
   - User menu (profile, settings, logout)

2. **Page Header**
   - Page title
   - Breadcrumbs (when nested)
   - Primary action button (if applicable)

3. **Main Content**
   - Relevant data display (use mock data)
   - Forms (with proper labels and validation styling)
   - Tables (with sorting, pagination mock)
   - Cards for listings/deals
   - Empty states

4. **Sidebar** (when applicable)
   - Filters
   - Quick actions
   - Related info
   - Help tips

5. **Footer**
   - Legal links
   - Contact info
   - Copyright

### Component Patterns

- **Tables:** Sortable headers, action buttons, status badges
- **Forms:** Labels, inputs, help text, validation messages, submit button
- **Cards:** Image, title, key info, actions
- **Modals:** Confirmation dialogs (can be mockups)
- **Alerts:** Success, error, info, warning messages
- **Loading States:** Skeleton screens or spinners
- **Empty States:** Friendly message and CTA

---

## Implementation Notes

1. **All routes must work** - No broken links
2. **Navigation consistency** - Same nav structure per role
3. **Breadcrumbs** - Help users understand location
4. **Mock data** - Realistic sample data in views
5. **Responsive** - All views work on mobile/tablet/desktop
6. **French language** - All text in French
7. **Icons from Lucide** - Consistent iconography
8. **Tailwind styling** - Follow style guide
9. **No actual CRUD** - Just mockups, no database operations
10. **Stimulus only when needed** - For interactive elements (drag-drop CRM, timers)

---

## Priority Routes (Phase 1 - Must Have)

Start with these essential routes:

**Public:**
- Landing page
- Login
- Registration (all types)
- Browse listings
- Pricing

**Admin:**
- Dashboard
- Users index
- Listings pending validation
- Deals index

**Seller:**
- Dashboard
- My listings
- Create listing
- Listing detail

**Buyer:**
- Dashboard
- Browse listings
- CRM Pipeline
- Listing detail (after NDA)
- Subscription management

**Partner:**
- Dashboard
- Profile edit
- Directory profile view

This covers ~30 core routes that demonstrate all major user journeys.
