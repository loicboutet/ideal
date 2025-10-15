# Quick Start Guide - Idéal Reprise Mockups

## 🎯 Goal

Create visual mockups for **every route** defined in [`routes.md`](routes.md) following the specifications in [`specifications.md`](specifications.md), using the models structure from [`models.md`](models.md), and applying the design from [`style_guide.md`](style_guide.md).

## 📋 What You Need to Know

### The Project
- **Platform:** Business acquisition marketplace (sellers, buyers, partners)
- **Phase:** Mockup development (no real database/auth needed)
- **Language:** French interface, English documentation
- **Tech:** Rails 8, Tailwind CSS, Lucide Icons, Stimulus (minimal)
- **Deployment:** Automatic to https://ideal.5000.dev on push to main

### The Docs
1. **[specifications.md](specifications.md)** - What features are needed
2. **[models.md](models.md)** - Data structure (for reference only)
3. **[routes.md](routes.md)** - Every route to create (~110 routes)
4. **[style_guide.md](style_guide.md)** - Design guidelines
5. **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Detailed how-to

## 🚀 Quick Start (5 Steps)

### 1. Understand the User Roles

- **Admin:** Manages platform, validates listings/partners
- **Seller (Cédant):** Posts business listings
- **Buyer (Repreneur):** Browses and manages deals via CRM
- **Partner:** Service providers (lawyers, accountants)
- **Public:** Anyone browsing without login

### 2. Start with Priority Routes

Focus on these 30 routes first (see [routes.md](routes.md) for full list):

**Public (9 routes):**
- Landing page
- Login/Register pages
- Browse listings
- Pricing

**Admin (8 routes):**
- Dashboard
- Users list
- Listings validation
- Deals overview

**Seller (6 routes):**
- Dashboard
- My listings
- Create/edit listing

**Buyer (8 routes):**
- Dashboard
- Browse listings
- CRM Pipeline
- Subscription

**Partner (3 routes):**
- Dashboard
- Edit profile
- Public directory view

### 3. Create Controller Structure

```ruby
# Example: Creating buyer's listings controller

# 1. Create file: app/controllers/mockups/buyer/listings_controller.rb
module Mockups
  module Buyer
    class ListingsController < ApplicationController
      layout 'mockup_user'
      skip_before_action :authenticate_user!
      
      def index
        # Mock data will go here
      end
      
      def show
        # Mock data will go here
      end
    end
  end
end

# 2. Add routes in config/routes.rb
namespace :mockups do
  namespace :buyer do
    resources :listings, only: [:index, :show]
  end
end

# 3. Create views
# app/views/mockups/buyer/listings/index.html.erb
# app/views/mockups/buyer/listings/show.html.erb
```

### 4. Use the Right Layout

Three layouts available:

1. **`mockup.html.erb`** - Public pages (create this)
2. **`mockup_user.html.erb`** - Sellers/Buyers/Partners (exists, update)
3. **`mockup_admin.html.erb`** - Admin pages (exists, update)

### 5. Add Mock Data

Create realistic French data:

```ruby
# app/helpers/mock_data_helper.rb
module MockDataHelper
  def mock_listings
    [
      {
        id: 1,
        title: "Boulangerie traditionnelle - Paris 11ème",
        annual_revenue: 450000,
        asking_price: 180000,
        location: "Paris",
        status: "published"
      },
      # ... more listings
    ]
  end
  
  def mock_companies
    ["Boulangerie Moderne", "Restaurant Le Gourmet", "Garage Auto Plus"]
  end
end
```

## 🎨 Design Guidelines

### Colors (from Bonjour Cactus style)
- Professional, clean palette
- Use Tailwind's built-in colors
- Primary: Blue tones
- Accent: Warm highlights for CTAs

### Typography
- Inter font (already included)
- Clear hierarchy
- 16px base font size

### Components
- Cards for listings/deals
- Tables with sorting
- Forms with validation styling
- Empty states
- Loading states
- Badges for status

### Icons
Use Lucide Icons (https://lucide.dev/):
```erb
<!-- Example: User icon -->
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-user">
  <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>
```

### Responsive
- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

Use Tailwind responsive classes:
```html
<div class="flex flex-col md:flex-row lg:grid lg:grid-cols-3">
```

## 📝 Checklist for Each Route

- [ ] Read related specification
- [ ] Check models.md for data structure
- [ ] Create controller with action
- [ ] Add route in routes.rb
- [ ] Create view file
- [ ] Add mock data
- [ ] Use correct layout
- [ ] Add navigation
- [ ] Use French language
- [ ] Add Lucide icons
- [ ] Make responsive
- [ ] Test in browser
- [ ] Push to main
- [ ] Verify on https://ideal.5000.dev

## ⚠️ Important Don'ts

❌ **DON'T:**
- Create database migrations
- Create Active Record models
- Add real authentication logic
- Make actual API calls
- Process real payments
- Upload actual files
- Use Stimulus unless necessary

✅ **DO:**
- Create mockup controllers/views only
- Use mock/fake data
- Show realistic UI states
- Follow French language
- Make it look professional
- Keep code simple (KISS)

## 🔍 Finding Information

| Need to know... | Check... |
|----------------|----------|
| What features exist | `specifications.md` |
| What data to display | `models.md` |
| What pages to create | `routes.md` |
| How it should look | `style_guide.md` |
| How to implement | `IMPLEMENTATION_GUIDE.md` |

## 💻 Development Workflow

```bash
# 1. Check current state
git status

# 2. Create feature branch (optional)
git checkout -b mockup-buyer-listings

# 3. Make changes
# - Create controllers
# - Add routes
# - Create views

# 4. Test locally
touch tmp/restart.txt  # restart server if needed
# Open http://localhost:3000/mockups in browser

# 5. Commit and push
git add .
git commit -m "Add buyer listings mockup"
git push origin main  # or your branch

# 6. Verify deployment
# Check https://ideal.5000.dev after ~2 minutes
```

## 🎯 Success Criteria

Your mockup is good when:
- ✅ Loads without errors
- ✅ Looks professional
- ✅ Uses French language
- ✅ Responsive on mobile/tablet/desktop
- ✅ Has realistic mock data
- ✅ Navigation works
- ✅ Matches style guide
- ✅ Follows specifications

## 📚 Key Routes Reference

### Public
- `/mockups` - Landing
- `/mockups/login` - Login
- `/mockups/listings` - Browse

### Admin
- `/mockups/admin` - Dashboard
- `/mockups/admin/users` - Users
- `/mockups/admin/listings/pending` - Validate

### Seller
- `/mockups/seller` - Dashboard
- `/mockups/seller/listings` - My listings
- `/mockups/seller/listings/new` - Create

### Buyer
- `/mockups/buyer` - Dashboard
- `/mockups/buyer/listings` - Browse
- `/mockups/buyer/pipeline` - CRM

### Partner
- `/mockups/partner` - Dashboard
- `/mockups/directory/:id` - Public profile

## 🆘 Need Help?

1. Read the relevant doc file
2. Look at existing mockup examples
3. Check Tailwind docs: https://tailwindcss.com
4. Check Lucide icons: https://lucide.dev
5. Reference Bonjour Cactus: https://www.bonjourcactus.com

## 🎉 Let's Build!

Start with the landing page (`/mockups`), then move through each user type systematically. Keep it simple, keep it clean, keep it in French!

**Bon courage! 🚀**
