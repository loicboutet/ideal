# Platform Specifications - Idéal Reprise

## Project Overview

**Platform Name:** Idéal Reprise  
**Purpose:** Business acquisition marketplace platform connecting company sellers, buyers, partners, and investors  
**Target Market:** Low/mid cap business transfers in the context of "papy boom"  
**Business Model:** Freemium platform with club membership levels

---

## BRICK 1 - Marketplace & Basic CRM (€5000)

### User Roles

#### 1. Admin (Idéal Reprise Team)

**Account Management:**
- Create and manage user accounts
- Manually validate seller listings
- Validate partner profiles
- Bulk import existing leads (800+ contacts via Excel)
- Assign exclusive deals to specific buyers

**Dashboard Access:**
- View key metrics dashboard:
  - Platform traffic
  - Registered users
  - Deals by status
  - Revenue (CA)

---

#### 2. Seller (Cédant)

**Registration & Profile:**
- Free registration
- Create business listing with:
  - Annual revenue (CA)
  - Employee count
  - Profits
  - Location
  - Asking price / price range

**Listing Management:**
- View listings pending validation
- Sign NDA before contacting buyers (if paid option)
- Free access to first 3-4 buyer contacts
- Pay to directly contact additional buyers

---

#### 3. Buyer (Repreneur)

**Registration & Access:**
- Register and browse all listings (freemium with payment pop-up)
- Must sign mandatory NDA before accessing listing details

**Subscription Plans:**
- €89/month
- €199/month
- €249/month
- €1200/year (club membership)

**Listing Interaction:**
- Reserve a listing with automatic timer:
  - 2 months maximum for club members
  - 10 days for other plans
- Enrich listings (add financial statements, info) to earn credits
- Favorite listings (even if reserved by others)
- Release listings back to common pool
- Delete deals from history

**CRM Features:**
- Drag & drop pipeline with statuses:
  - To Contact (À contacter)
  - In Relationship (En relation)
  - Under Study (En cours d'études)
  - Negotiations (Négociations)
  - Signed/Finalized (Signé/Finalisé)

---

#### 4. Partner (Service Providers)

**Types:** Lawyers, accountants, consultants, etc.

**Profile Management:**
- Register with manual profile validation
- Create directory listing:
  - Company presentation
  - Google Calendar link for appointments
- Edit profile information
- Pay annual directory subscription

---

### Core System Features

#### Authentication & Authorization
- Multi-profile user system (Admin, Seller, Buyer, Partner)
- Role-based access control
- Secure login/logout

#### Payment System
- Integrated Stripe payment processing
- Subscription management
- Credit system for buyers

#### Listing Management
- Full CRUD operations for listings
- Admin validation workflow
- Status tracking
- Search and filtering

#### CRM System
- Drag & drop interface for buyers
- Pipeline status management
- Deal history tracking

#### Reservation System
- Automatic timer-based reservations:
  - Club members: 2 months
  - Other plans: 10 days
- Automatic release to pool when timer expires
- Manual release option

#### Bulk Import
- Excel import for existing leads
- Deal assignment to specific buyers

#### Scoring System
- Star/scorecard for listing completeness
- Credit rewards for enriching listings

#### NDA System
- Electronic NDA signing
- Required before:
  - Accessing listing details
  - Contacting sellers

#### Email Notifications
- New deal available
- Listing validated
- Favorited deal available
- Listing approved

#### Interface
- Responsive web application
- Mobile-optimized views
- No native mobile app

---

## Explicitly Excluded Features (Brick 1)

The following are NOT included in Brick 1:

- Native mobile applications (iOS/Android)
- Crowdfunding/fundraising with transactions
- Internal messaging system between users
- Integrated video conferencing
- Financial transactions for investments
- Advanced accounting features
- External CRM integration
- White-label crowdfunding platform development
- Regulatory compliance management (handled by partner)

---

## Technical Requirements

### Frontend
- Responsive web design (mobile-first)
- Modern UI/UX
- French interface
- Optimized for desktop and mobile browsers

### Backend
- Ruby on Rails 8
- SQLite with Solid libraries
- RESTful API design
- Secure data handling

### Integrations
- Stripe for payments
- Email delivery system
- Excel import/export

### Security
- GDPR compliance
- Secure authentication
- Data encryption
- Electronic signature for NDAs

### Performance
- Fast page loads
- Optimized database queries
- Caching where appropriate

---

## Future Bricks (Not in Scope)

This specification covers only Brick 1. Future bricks are:
- **Brick 2:** Advanced features (TBD)
- **Brick 3:** Additional features (TBD)

Each brick is independent and optional.
