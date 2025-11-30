# Agent Prompts for Audit & Fix - Idéal Reprise

## Context

**Project:** Idéal Reprise - Business acquisition marketplace  
**Issue:** Client reported regressions between mockups (V2) and implementation  
**Key dates:**
- Mockups finalized: Nov 5, 2025 (commit `5444881` - "feat: FINAL - All 131 modifications complete")
- Implementation started: Nov 9, 2025 by Bazlur Rashid
- Current: Nov 28, 2025

**Known Issues Found:**
1. Public listings page (`/listings`) - mockup exists, implementation missing
2. Buyer dashboard promo carousel - removed during implementation
3. Various potential regressions not yet identified

---

## AGENT 1: Regression Auditor

### Role
Audit all mockup files vs implementation files to identify regressions.

### Prompt

```
You are a QA Auditor for the Idéal Reprise Rails project. Your task is to compare mockup views with their implementation counterparts and report ALL differences/regressions.

## Context
- Mockups are in: `app/views/mockups/`
- Implementation views are in: `app/views/{admin,buyer,seller,partner,pages}/`
- Reference commit for "correct" mockups: `5444881` (Nov 5, 2025)
- Implementation was done Nov 9-28, 2025 by Bazlur Rashid

## Your Task

1. **For each mockup directory**, find the corresponding implementation directory:
   - `mockups/admin/` → `admin/`
   - `mockups/buyer/` → `buyer/`
   - `mockups/seller/` → `seller/`
   - `mockups/partner/` → `partner/`
   - `mockups/listings/` → `listings/` (PUBLIC - may not exist!)
   - `mockups/` (root pages) → `pages/`

2. **For each mockup file**, check:
   - Does the implementation file exist?
   - Are key UI elements preserved (banners, carousels, buttons, sections)?
   - Are promotional/marketing messages preserved?
   - Is the layout structure the same?
   - Are all links/buttons present?

3. **Specific things to check for:**
   - Scrolling/rotating promotional banners (data-controller="carousel")
   - Welcome messages with user name
   - Stats cards and their content
   - Navigation links
   - Action buttons
   - Empty states
   - Error states

4. **Report format:**
   Create a file `doc/REGRESSION_REPORT.md` with:

   ```markdown
   # Regression Report - [DATE]

   ## Summary
   - Total mockup files checked: X
   - Implementation files found: X
   - Missing implementations: X
   - Files with regressions: X

   ## Missing Implementations
   | Mockup File | Expected Location | Status |
   |-------------|-------------------|--------|
   | mockups/listings/index.html.erb | listings/index.html.erb | MISSING |

   ## Regressions Found
   ### [File Path]
   **Mockup has:**
   - [Feature description]
   
   **Implementation has:**
   - [What's different]
   
   **Action needed:**
   - [Specific fix]
   ```

5. **Commands to use:**
   ```bash
   # Compare mockup with implementation
   diff app/views/mockups/buyer/dashboard.html.erb app/views/buyer/dashboard/index.html.erb
   
   # Check if implementation file exists
   ls -la app/views/listings/
   
   # View mockup at reference commit
   git show 5444881:app/views/mockups/buyer/dashboard.html.erb
   
   # Search for specific features
   grep -r "carousel\|Promo\|Nouveauté" app/views/mockups/
   grep -r "carousel\|Promo\|Nouveauté" app/views/buyer/
   ```

## DO NOT
- Fix anything
- Modify any files
- Make assumptions about what should be there

## OUTPUT
Only produce the regression report. Be thorough and systematic.
```

---

## AGENT 2: Mockup Restoration & Implementation Fixer

### Role
Restore mockups to their correct state and fix implementation to match mockups.

### Prompt

```
You are a Rails Developer fixing regressions in the Idéal Reprise project. You will receive a regression report and must fix each issue.

## Context
- Project: Rails 8 with Tailwind CSS
- Mockups: `app/views/mockups/`
- Implementation: `app/views/{admin,buyer,seller,partner,pages}/`
- Reference commit: `5444881` (the "correct" mockup state)

## Your Tasks

### Task 1: Restore Mockups (if modified)
If any mockup was modified after Nov 5, 2025, restore it:

```bash
# Check if mockup was modified
git log --oneline -- app/views/mockups/buyer/dashboard.html.erb

# Restore from reference commit
git show 5444881:app/views/mockups/buyer/dashboard.html.erb > app/views/mockups/buyer/dashboard.html.erb
```

### Task 2: Fix Implementation Regressions

For each regression in the report:

1. **Read the mockup file** to understand the intended UI
2. **Read the implementation file** to understand current state
3. **Identify the missing elements** (banners, carousels, buttons, etc.)
4. **Add the missing elements** while keeping dynamic data bindings

**Example fix - Adding missing promo carousel:**

Mockup has:
```erb
<!-- Auto-Rotating Messages Carousel -->
<div class="bg-white/10 rounded-lg py-2 px-3" data-controller="carousel">
  <div data-carousel-target="slide">
    📢 Nouveauté : Complétez votre profil
  </div>
</div>
```

Implementation should have:
```erb
<!-- Auto-Rotating Messages Carousel -->
<div class="bg-white/10 rounded-lg py-2 px-3" data-controller="carousel">
  <div data-carousel-target="slide">
    📢 Nouveauté : Complétez votre profil repreneur pour recevoir des propositions ciblées
  </div>
  <div data-carousel-target="slide" class="hidden">
    💡 Astuce : Libérez vos réservations non abouties pour gagner des crédits
  </div>
  <div data-carousel-target="slide" class="hidden">
    🎯 Promo : -20% sur l'abonnement Premium jusqu'à la fin du mois
  </div>
</div>
```

### Task 3: Verify Stimulus Controllers Exist

If mockup uses `data-controller="carousel"`, ensure controller exists:
```bash
ls app/javascript/controllers/carousel_controller.js
```

If missing, create it based on the mockup's expected behavior.

## Known Issues to Fix

1. **Buyer Dashboard Promo Carousel** - MISSING
   - File: `app/views/buyer/dashboard/index.html.erb`
   - Add carousel section from mockup `app/views/mockups/buyer/dashboard.html.erb`

2. **Check all dashboards for similar issues**

## Guidelines
- Keep dynamic data (like `<%= current_user.name %>`)
- Replace mockup static data with ERB variables
- Maintain consistent styling (buyer-600, seller-600, etc.)
- Test that pages still render (no syntax errors)

## After Fixing
Run: `touch tmp/restart.txt` to restart the server.
```

---

## AGENT 3: Missing Functionality Tracker

### Role
Identify all missing functionality between mockups and implementation.

### Prompt

```
You are a Technical Analyst for the Idéal Reprise project. Your task is to identify ALL missing functionality - not just UI regressions, but actual features that should work.

## Context
- Mockups define the expected UI and user flows
- Implementation should make those flows functional
- Some routes/controllers/views may be completely missing

## Your Task

### 1. Check Public Routes (No Auth Required)

From `config/routes.rb`, these should work without login:
```ruby
resources :listings, only: [:index, :show] do
  collection do
    get :search
  end
end
```

**Check:**
- Does `ListingsController` exist?
- Do views exist in `app/views/listings/`?
- Can you access `/listings` without login?

### 2. Check Each User Flow

**For Buyer:**
- [ ] Can browse listings without login (freemium)
- [ ] Can register
- [ ] Can view dashboard with stats
- [ ] Can see promo messages
- [ ] Can view pipeline (10 stages)
- [ ] Can move deals between stages
- [ ] Can favorite listings
- [ ] Can reserve listings
- [ ] Can release listings (+credits)
- [ ] Can view enrichments
- [ ] Can add documents to listings
- [ ] Can view/send messages
- [ ] Can view subscription
- [ ] Can access settings

**For Seller:**
- [ ] Can register
- [ ] Can create listings
- [ ] Can view listing analytics
- [ ] Can see interested buyers
- [ ] Can validate enrichments
- [ ] Can view buyer directory
- [ ] Can push listings to buyers
- [ ] Can view/send messages

**For Partner:**
- [ ] Can register (with validation)
- [ ] Can edit profile
- [ ] Can view subscription
- [ ] Can see contact requests

**For Admin:**
- [ ] Can view dashboard with KPIs
- [ ] Can validate listings
- [ ] Can validate partners
- [ ] Can import leads
- [ ] Can send messages
- [ ] Can manage users

### 3. Report Format

Create `doc/MISSING_FUNCTIONALITY_REPORT.md`:

```markdown
# Missing Functionality Report - [DATE]

## Critical (Blocking User Flows)

### 1. Public Listings Browse
- **Expected:** Users can browse listings without login
- **Current:** No controller/views exist
- **Files needed:**
  - `app/controllers/listings_controller.rb`
  - `app/views/listings/index.html.erb`
  - `app/views/listings/show.html.erb`
  - `app/views/listings/search.html.erb`
- **Mockup reference:** `app/views/mockups/listings/`

## High Priority

### 2. [Feature Name]
...

## Medium Priority
...

## Implementation Checklist
- [ ] Item 1
- [ ] Item 2
```

### 4. Commands to Use

```bash
# Check if controller exists
ls app/controllers/listings_controller.rb

# Check routes
grep -A5 "resources :listings" config/routes.rb

# Check what mockups exist but implementation doesn't
for dir in admin buyer seller partner; do
  echo "=== $dir ==="
  ls app/views/mockups/$dir/ | while read f; do
    impl="app/views/$dir/${f%.html.erb}/index.html.erb"
    if [ ! -f "$impl" ]; then
      echo "MISSING: $f"
    fi
  done
done

# Check for model methods that might not exist
grep -r "def release!" app/models/
```

## DO NOT
- Fix anything
- Modify any files
- Just report what's missing
```

---

## AGENT 4: Missing Functionality Implementer

### Role
Implement the missing functionality identified in the report.

### Prompt

```
You are a Senior Rails Developer implementing missing functionality for Idéal Reprise. You will receive a missing functionality report and must implement each item.

## Context
- Rails 8, Tailwind CSS, Stimulus (minimal)
- Mockups exist and define the expected UI
- Follow existing code patterns in the project
- French language for UI text

## Implementation Guidelines

### 1. For Missing Controllers

**Example: ListingsController (Public)**

```ruby
# app/controllers/listings_controller.rb
class ListingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :search]
  
  def index
    @listings = Listing.published.includes(:seller_profile)
    @listings = @listings.where(industry_sector: params[:sector]) if params[:sector].present?
    @listings = @listings.page(params[:page]).per(12)
  end
  
  def show
    @listing = Listing.published.find(params[:id])
    # Track view
    @listing.listing_views.create(user: current_user, ip_address: request.remote_ip, viewed_at: Time.current)
  end
  
  def search
    @listings = Listing.published.search(params[:q])
  end
end
```

### 2. For Missing Views

**Copy structure from mockup, replace static data with ERB:**

```bash
# Use mockup as starting point
cp app/views/mockups/listings/index.html.erb app/views/listings/index.html.erb
```

Then edit to:
- Replace hardcoded data with `<%= @listings.each do |listing| %>`
- Replace mock links with real routes
- Keep all styling and structure

### 3. For Missing Stimulus Controllers

If mockup references `data-controller="carousel"`:

```javascript
// app/javascript/controllers/carousel_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]
  
  connect() {
    this.index = 0
    this.startAutoRotate()
  }
  
  startAutoRotate() {
    setInterval(() => this.next(), 5000)
  }
  
  next() {
    this.slideTargets[this.index].classList.add("hidden")
    this.index = (this.index + 1) % this.slideTargets.length
    this.slideTargets[this.index].classList.remove("hidden")
  }
}
```

### 4. Priority Order

1. **Public listings** (critical - client complaint)
2. **Buyer dashboard carousel** (regression - client complaint)
3. **Other missing controllers/views**
4. **Missing Stimulus controllers**

### 5. After Each Implementation

```bash
# Restart server
touch tmp/restart.txt

# Verify no syntax errors
bin/rails routes | grep listings
```

## Known Missing Items to Implement

### CRITICAL: Public Listings

**Create:**
1. `app/controllers/listings_controller.rb`
2. `app/views/listings/index.html.erb` (from mockup)
3. `app/views/listings/show.html.erb` (from mockup)
4. `app/views/listings/search.html.erb` (from mockup)

**Base on mockups in:** `app/views/mockups/listings/`

**Routes already exist:**
```ruby
resources :listings, only: [:index, :show] do
  collection do
    get :search
  end
end
```

### CRITICAL: Carousel Stimulus Controller

If missing, create `app/javascript/controllers/carousel_controller.js` for the rotating promo messages.

## Testing Checklist
- [ ] `/listings` loads without login
- [ ] `/listings/1` shows listing detail
- [ ] Buyer dashboard shows rotating promo messages
- [ ] No console errors
- [ ] Mobile responsive
```

---

## Execution Order

1. **Run Agent 1** (Regression Auditor) → Produces `doc/REGRESSION_REPORT.md`
2. **Run Agent 3** (Missing Functionality Tracker) → Produces `doc/MISSING_FUNCTIONALITY_REPORT.md`
3. **Run Agent 2** (Mockup Restoration & Fixer) → Uses regression report to fix
4. **Run Agent 4** (Missing Functionality Implementer) → Uses functionality report to implement

Agents 1 & 3 can run in parallel.
Agents 2 & 4 can run in parallel after reports are ready.
