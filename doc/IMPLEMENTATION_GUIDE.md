# Implementation Guide - Idéal Reprise Mockups

## 📋 Overview

This guide provides a roadmap for implementing all mockups defined in the project documentation.

## 🎯 Current State

### ✅ Completed
- Project documentation (specifications, models, routes, style guide)
- Base mockup infrastructure:
  - `MockupsController` with layout resolver
  - `mockup_admin.html.erb` layout
  - `mockup_user.html.erb` layout
  - Sample mockup views (7 views created)
- Tailwind CSS configured
- Inter font included
- Devise setup for future authentication

### 📊 Statistics
- **Total Routes to Create:** ~110 routes
- **Existing Routes:** 7 mockup routes
- **Remaining Routes:** ~103 routes
- **Priority Routes:** 30 core routes

## 🏗 Implementation Strategy

### Phase 1: Core Infrastructure (DONE ✅)
- [x] Create documentation
- [x] Set up base mockup controller
- [x] Create layout templates
- [x] Configure Tailwind CSS

### Phase 2: Priority Routes (NEXT 🎯)

Create the 30 most important routes first:

#### Public Pages (5 routes)
- [ ] `/mockups` - Landing page (exists, needs update)
- [ ] `/mockups/login` - Login page
- [ ] `/mockups/register` - Registration choice
- [ ] `/mockups/register/seller` - Seller registration
- [ ] `/mockups/register/buyer` - Buyer registration
- [ ] `/mockups/register/partner` - Partner registration
- [ ] `/mockups/listings` - Browse listings (public)
- [ ] `/mockups/listings/:id` - Listing detail (teaser)
- [ ] `/mockups/pricing` - Pricing page

#### Admin Routes (8 routes)
- [ ] `/mockups/admin` - Dashboard (exists, needs update)
- [ ] `/mockups/admin/users` - Users list (exists, needs update)
- [ ] `/mockups/admin/listings` - All listings
- [ ] `/mockups/admin/listings/pending` - Pending validation
- [ ] `/mockups/admin/listings/:id` - Listing detail
- [ ] `/mockups/admin/deals` - All deals
- [ ] `/mockups/admin/partners` - All partners
- [ ] `/mockups/admin/partners/pending` - Pending partners

#### Seller Routes (6 routes)
- [ ] `/mockups/seller` - Seller dashboard
- [ ] `/mockups/seller/listings` - My listings
- [ ] `/mockups/seller/listings/new` - Create listing
- [ ] `/mockups/seller/listings/:id` - Listing detail
- [ ] `/mockups/seller/listings/:id/edit` - Edit listing
- [ ] `/mockups/seller/profile/edit` - Edit profile

#### Buyer Routes (8 routes)
- [ ] `/mockups/buyer` - Buyer dashboard
- [ ] `/mockups/buyer/listings` - Browse listings
- [ ] `/mockups/buyer/listings/:id` - Listing detail (full)
- [ ] `/mockups/buyer/pipeline` - CRM Pipeline (drag & drop)
- [ ] `/mockups/buyer/deals` - My deals list
- [ ] `/mockups/buyer/favorites` - Favorited listings
- [ ] `/mockups/buyer/subscription` - Subscription management
- [ ] `/mockups/buyer/nda/listing/:id` - Sign NDA

#### Partner Routes (3 routes)
- [ ] `/mockups/partner` - Partner dashboard
- [ ] `/mockups/partner/profile/edit` - Edit directory profile
- [ ] `/mockups/directory/:id` - Public partner profile

### Phase 3: Secondary Routes (~40 routes)
Complete remaining CRUD operations and detail pages for each user type.

### Phase 4: Supporting Routes (~33 routes)
Add search, filters, notifications, settings, and legal pages.

## 📁 File Structure to Create

```
app/
├── controllers/
│   ├── mockups_controller.rb (exists, needs update)
│   └── mockups/
│       ├── admin_controller.rb (NEW)
│       ├── admin/
│       │   ├── users_controller.rb (NEW)
│       │   ├── listings_controller.rb (NEW)
│       │   ├── partners_controller.rb (NEW)
│       │   ├── deals_controller.rb (NEW)
│       │   ├── imports_controller.rb (NEW)
│       │   └── enrichments_controller.rb (NEW)
│       ├── seller_controller.rb (NEW)
│       ├── seller/
│       │   ├── listings_controller.rb (NEW)
│       │   ├── interests_controller.rb (NEW)
│       │   ├── profile_controller.rb (NEW)
│       │   ├── settings_controller.rb (NEW)
│       │   └── subscription_controller.rb (NEW)
│       ├── buyer_controller.rb (NEW)
│       ├── buyer/
│       │   ├── listings_controller.rb (NEW)
│       │   ├── pipeline_controller.rb (NEW)
│       │   ├── deals_controller.rb (NEW)
│       │   ├── favorites_controller.rb (NEW)
│       │   ├── reservations_controller.rb (NEW)
│       │   ├── enrichments_controller.rb (NEW)
│       │   ├── credits_controller.rb (NEW)
│       │   ├── subscription_controller.rb (NEW)
│       │   ├── profile_controller.rb (NEW)
│       │   ├── settings_controller.rb (NEW)
│       │   └── nda_controller.rb (NEW)
│       ├── partner_controller.rb (NEW)
│       ├── partner/
│       │   ├── profile_controller.rb (NEW)
│       │   ├── settings_controller.rb (NEW)
│       │   └── subscription_controller.rb (NEW)
│       ├── auth_controller.rb (NEW)
│       ├── listings_controller.rb (NEW)
│       ├── directory_controller.rb (NEW)
│       ├── notifications_controller.rb (NEW)
│       ├── legal_controller.rb (NEW)
│       ├── checkout_controller.rb (NEW)
│       └── errors_controller.rb (NEW)
├── views/
│   ├── layouts/
│   │   ├── mockup.html.erb (NEW - for public pages)
│   │   ├── mockup_admin.html.erb (exists, needs update)
│   │   └── mockup_user.html.erb (exists, needs update)
│   └── mockups/
│       ├── index.html.erb (exists, needs update)
│       ├── about.html.erb (NEW)
│       ├── how_it_works.html.erb (NEW)
│       ├── pricing.html.erb (NEW)
│       ├── contact.html.erb (NEW)
│       ├── auth/ (NEW)
│       ├── listings/ (NEW)
│       ├── admin/ (NEW)
│       ├── seller/ (NEW)
│       ├── buyer/ (NEW)
│       ├── partner/ (NEW)
│       ├── directory/ (NEW)
│       ├── notifications/ (NEW)
│       ├── legal/ (NEW)
│       ├── checkout/ (NEW)
│       └── errors/ (NEW)
```

## 🎨 Design Guidelines

### Layouts to Create/Update

1. **`mockup.html.erb`** (NEW)
   - For public pages (landing, login, register, etc.)
   - Clean header with logo and navigation
   - Simple footer with legal links
   - No authentication required

2. **`mockup_user.html.erb`** (UPDATE)
   - For sellers, buyers, partners
   - Top navigation with user menu
   - Role-specific navigation items
   - Breadcrumbs for deep pages

3. **`mockup_admin.html.erb`** (UPDATE)
   - Sidebar navigation (already has)
   - Admin-specific menu items from routes.md
   - Stats in header

### Component Patterns

Create reusable partials:
- `_navigation.html.erb` - Main nav component
- `_sidebar.html.erb` - Sidebar for admin
- `_card.html.erb` - Card component for listings/deals
- `_table.html.erb` - Table component
- `_form_field.html.erb` - Form field with label/error
- `_button.html.erb` - Button styles
- `_badge.html.erb` - Status badges
- `_empty_state.html.erb` - Empty state component
- `_alert.html.erb` - Alert/notification component

### Mock Data

Create helper modules:
- `MockDataHelper` - Generate realistic French mock data
  - User names
  - Company names
  - Addresses
  - Financial figures
  - Dates

## 🔧 Technical Implementation

### Controller Inheritance Pattern

```ruby
# Base controller
class MockupsController < ApplicationController
  layout 'mockup'
  skip_before_action :authenticate_user!
end

# Admin namespace
module Mockups
  class AdminController < MockupsController
    layout 'mockup_admin'
  end
end

# Nested controllers
module Mockups
  module Admin
    class UsersController < AdminController
      # actions here
    end
  end
end
```

### Route Organization

Update `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ... existing routes ...
  
  # Mockups
  namespace :mockups do
    root to: 'mockups#index'
    
    # Public pages
    get 'about', to: 'mockups#about'
    get 'pricing', to: 'mockups#pricing'
    # etc.
    
    # Auth
    scope module: 'auth' do
      get 'login', to: 'auth#login'
      # etc.
    end
    
    # Admin
    namespace :admin do
      root to: 'admin#dashboard'
      resources :users
      resources :listings
      # etc.
    end
    
    # Seller
    namespace :seller do
      root to: 'seller#dashboard'
      resources :listings
      # etc.
    end
    
    # Buyer
    namespace :buyer do
      root to: 'buyer#dashboard'
      resources :listings, only: [:index, :show]
      # etc.
    end
    
    # Partner
    namespace :partner do
      root to: 'partner#dashboard'
      # etc.
    end
  end
end
```

## 📝 Checklist for Each Route

When creating a new mockup route:

- [ ] Create/update controller with action
- [ ] Add route to `config/routes.rb`
- [ ] Create view file
- [ ] Use appropriate layout
- [ ] Add navigation links
- [ ] Include mock data
- [ ] Add breadcrumbs (if nested)
- [ ] Test in browser
- [ ] Check mobile responsiveness
- [ ] Use French language
- [ ] Use Lucide icons
- [ ] Follow style guide

## 🚀 Next Steps

1. **Read all documentation** in `/doc` folder
2. **Start with public pages** (landing, login, register)
3. **Create base layout** (`mockup.html.erb`)
4. **Update existing layouts** with proper navigation
5. **Create mock data helper**
6. **Build priority routes** (30 routes)
7. **Test on https://ideal.5000.dev** after push to main
8. **Iterate and complete** remaining routes

## 🎓 Learning Resources

- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Lucide Icons](https://lucide.dev/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/)
- [Rails Routing Guide](https://guides.rubyonrails.org/routing.html)
- [Bonjour Cactus](https://www.bonjourcactus.com/) (design reference)

## 💡 Tips

1. **Keep views small** - Use partials for reusable components
2. **Mock data in helpers** - Don't hardcode in views
3. **Consistent navigation** - Same nav per role
4. **Mobile-first** - Design for mobile, enhance for desktop
5. **French everywhere** - All UI text in French
6. **KISS** - Keep It Simple, Stupid
7. **RESTful** - Follow REST conventions
8. **No real logic** - Just mockups, no database calls
9. **Use Stimulus sparingly** - Only for interactivity (CRM drag-drop)
10. **Test often** - Push to main and check on https://ideal.5000.dev

## 🐛 Troubleshooting

### Routes not working
- Check `config/routes.rb` syntax
- Verify controller namespace matches
- Ensure controller inherits correctly

### Layout not applied
- Check layout declaration in controller
- Verify layout file exists
- Check file naming conventions

### Styling not working
- Verify Tailwind classes
- Check if CSS is compiling
- Restart server with `touch tmp/restart.txt`

### Icons not showing
- Ensure using Lucide icon SVGs
- Check SVG syntax
- Verify class names

## 📊 Progress Tracking

Track your progress:

```
Total Routes: ~110
✅ Completed: 7
🚧 In Progress: 0
⏳ Remaining: 103

Progress: 6%
```

Update this as you complete routes!

---

**Good luck!** 🚀 Follow the documentation, stay consistent, and create beautiful mockups for Idéal Reprise.
