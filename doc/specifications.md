# Platform Specifications - Idéal Reprise

## Project Overview

**Platform Name:** Idéal Reprise  
**Purpose:** Business acquisition marketplace platform connecting company sellers, buyers (repreneurs), partners, and investors  
**Target Market:** Low/mid cap business transfers in the context of "papy boom"  
**Business Model:** Freemium platform with club membership levels

---

## BRICK 1 - Marketplace & Basic CRM (€4500)

### User Roles

#### 1. Admin (Idéal Reprise Team)

**Account Management:**
- Create and manage user accounts (all roles including seller profiles with listings)
- Manually validate seller listings
- Validate partner profiles
- Bulk import existing leads (800+ contacts via Excel)
- Assign exclusive deals to specific buyers
- Attribute deals during validation (for sourcing)

**Dashboard Access - Operations Center:**
- 4 Alert KPIs (clickable for details):
  - Listings with 0 views
  - Pending validations
  - Pending reports
  - Deals with expired timers
- Bar chart: Deals by CRM status (10 statuses, period selectable, clickable)
- Ratio: Available listings / Paying buyers
- Satisfaction: Current % + evolution
- Bar chart: Abandoned deals by status (stacked: voluntary vs timer)
- 4 Growth metrics:
  - Active listings
  - Monthly revenue
  - Total users
  - Reservations
- User distribution (with period evolution)
- Spending by user category (with period evolution)
- Partner usage: Views/contacts over X months

**Analytics Dashboard:**
- Bar chart: Average time per CRM status (with max time markers)
- Details: Listings/Reservations/Transactions by:
  - Sector
  - Revenue
  - Geography
  - Employee count
  - With evolution tracking
- Export data to spreadsheet

**Platform Settings:**
- Update pricing & offer texts
- Adjust pipeline timers per stage (min 1 week, max 2 months):
  - To Contact: 7 days
  - Info Exchange/Analysis/Alignment: 33 days
  - Negotiation: 20 days
  - LOI: Requires seller validation, pauses timer

**Communication:**
- Send messages to dashboard or direct
- Send satisfaction surveys
- Send development questionnaires

---

#### 2. Seller (Cédant)

**Registration & Profile:**
- Free registration
- Create business listing with:
  - **Public data:**
    - Generic business type (not specific name)
    - Department (not precise location)
    - Industry sector (11 predefined)
    - Annual revenue (CA)
    - Employee count
    - Profits
    - Asking price / price range
    - Transfer horizon
    - Transfer type (asset sale, shares, etc.)
    - Company age
    - Customer type (B2B, B2C, mixed)
  - **Confidential data** (after NDA):
    - Detailed description
    - Specific location
    - Company name
    - Website
    - Contact details
    - 11 document categories (40% of completeness)
    - Scorecard report (optional, with star display option)

**Listing Management:**
- View listings pending validation
- Track listing performance (views, interested buyers, CRM stages)
- See which buyers have favorited listings
- Upload/manage documents (11 categories)
- Completeness score & gauge
- Stage representation showing buyer progress in CRM

**Buyer Discovery:**
- Browse buyer directory (public profiles)
- View buyer profiles showing:
  - First name, formation, experience
  - Investment thesis
  - Subscription badge
  - Completeness %
- Push listings to matching buyers (1 credit per buyer)
- See buyers who favorited their listings

**Credits & Premium:**
- Earn credits for premium actions
- Buy credit packs
- Premium package for brokers:
  - Unlimited listings
  - Priority support
  - Partner directory access
  - Push listings to 5 buyers/month

**Assistance Menu:**
- Get accompanied (support offer + booking)
- Find partners (directory access, 5 credits, free first 6 months)
- Access tools

**Communication:**
- Internal messaging system
- Receive messages from interested buyers (after reservation)
- Validate enrichment documents added by buyers

---

#### 3. Buyer (Repreneur)

**Registration & Profile:**
- Register and create public/private profile:
  - **Public data:**
    - Buyer type (individual, holding, fund, investor)
    - Formation (incl. business acquisition)
    - Experience
    - Skills (200 chars)
    - Investment thesis (500 chars)
    - Target company: sectors, locations, revenue range, employees, financial health, transfer horizon, types, customer types
    - Financial data: Investment capacity, funding sources
  - **Confidential data:**
    - Full name
    - LinkedIn profile
    - (Future: Mastery assessment test)
- Completeness % and gauge
- "Verified Buyer" badge (premium, after 30min audit)

**Browse & Search:**
- Browse all listings (freemium with payment pop-up)
- Advanced filters including:
  - Deal type (Direct, Idéal Mandate, Partner Mandate)
  - Star rating
  - All new fields (horizon, transfer type, age, legal form, etc.)
  - 11 industry sectors
- Must sign mandatory NDA before accessing confidential details
- View completeness % and stars on listings

**Subscription Plans:**
- Free (limited)
- €89/month (Starter)
- €199/month (Standard)  
- €249/month (Premium)
- €1200/year (Club membership)
- Credit packs available

**Listing Interaction:**
- Favorite listings (even if reserved by others)
- Reserve listings with automatic timer
- Access confidential info after NDA + reservation
- Enrich listings (add documents) → Validated by SELLER → Earn credits
- Release listings (+1 credit + 1 per document added)
- Track time remaining with gauges

**CRM Features - 10 Stage Pipeline:**
1. Favorites
2. To Contact (7 days)
3. Info Exchange (33 days total for stages 3-5)
4. Analysis
5. Project Alignment
6. Negotiation (20 days)
7. LOI (requires seller validation, pauses timer)
8. Audits
9. Financing
10. Deal Signed
- Plus "Released Deals" section
- Drag & drop interface
- Visual timer + gauge per deal
- Time-extending stages highlighted
- Deal history tracking
- No backward movement (or no timer duplication)
- Automatic entry via favorites or reservation

**Document Management:**
- View uploaded documents
- Add documents (+1 credit, seller validates)
- 11 document categories with N/A options
- Documents visible to seller after validation

**Services Menu:**
- Personalized sourcing (on-demand booking)
- Partner directory (free for subscribers)
- Access tools

**Communication:**
- Internal messaging system
- Send messages to sellers (after reservation)
- Contact partners

**Matching:**
- See listings matching profile criteria
- Receive notifications of matches

---

#### 4. Partner (Service Providers)

**Types:** Lawyers, accountants, consultants, bankers, brokers

**Profile Management:**
- Register with manual profile validation
- Create directory listing with:
  - Company presentation
  - Services offered
  - Google Calendar link for appointments
  - Website
  - Coverage area (city, department, region, nationwide, international)
  - Intervention stages (CRM stages where they intervene)
  - Industry specialization (if any)
- Edit profile information
- Public directory profile vs detailed view
- Track views and contacts
- Pay annual directory subscription

**For Brokers (special seller profile):**
- Multi-listing premium package
- Publish mandates with "Partner Mandate" type
- Retro-commission contracts

---

### Core System Features

#### Authentication & Authorization
- Multi-profile user system (Admin, Seller, Buyer, Partner)
- Role-based access control
- Secure login/logout

#### Messaging System (NEW - Brick 1)
- Asynchronous internal messages
- Email notifications for new messages
- Real-time updates via Turbo Streams
- Message history (proof for NDA violations)
- Admin can broadcast messages/surveys
- No video conferencing (excluded)
- No live chat features (excluded)

#### Payment System
- Integrated Stripe payment processing
- Subscription management
- Credit system (multi-role: buyers, sellers, partners)
- Premium packages
- Credit packs

#### Listing Management
- Full CRUD operations for listings
- Admin validation workflow with deal attribution option
- Status tracking
- Search and filtering
- 3 deal types:
  - Direct Deal
  - Idéal Reprise Mandate
  - Partner Mandate
- Public/confidential data separation
- 11 document categories
- Completeness scoring (60% listing, 40% documents)

#### Buyer Profile System (NEW)
- Public/private profile for buyers
- Buyer directory searchable by sellers
- Profile completeness tracking
- Verification badge system
- Matching algorithm (listings ↔ profiles)

#### CRM System
- 10-stage pipeline (expanded from 5)
- Drag & drop interface
- Timer system with stage-specific durations
- Time-extending stages
- LOI stage with seller validation
- Automatic deal entry via favorites/reservations
- Deal history and timeline
- Released deals section
- No backward movement

#### Reservation System
- Automatic timer-based reservations
- Stage-specific timers:
  - To Contact: 7 days
  - Info Exchange/Analysis/Alignment: 33 days
  - Negotiation: 20 days
  - LOI: Seller validation required
- Visual gauges showing time remaining
- Automatic release to pool when timer expires
- Manual release option (+1 credit)
- Released deals tracking

#### Document System
- 11 predefined categories:
  1. Balance Sheet N-1
  2. Balance Sheet N-2
  3. Balance Sheet N-4
  4. Organization Chart
  5. Tax Return
  6. Income Statement
  7. Vehicle/Heavy Equipment List
  8. Lease Agreement
  9. Property Title
  10. Scorecard Report
  11. Other (specify)
- N/A checkboxes for non-applicable categories
- Document validation by seller (for buyer enrichments)
- Completeness tracking

#### Enrichment System
- Buyer enriches listings by adding documents
- **Seller validates** (changed from admin)
- Credit attribution at release:
  - +1 credit for voluntary release
  - +1 credit per document category added

#### Bulk Import
- Excel import for existing leads
- Deal assignment to specific buyers
- Automatic attribution for sourcing deals

#### Scoring System
- Star/scorecard for listing completeness
- Integration with external scorecard service
- Optional display of stars on public listings
- Profile completeness for buyers

#### NDA System
- Electronic "confidentiality agreement" (terminology change)
- Required before:
  - Accessing confidential listing details
  - Contacting sellers
- Signed NDAs tracked with proof
- Seller option to receive signed NDAs

#### Notifications
- Email notifications:
  - New deal available
  - Listing validated
  - Favorited deal available
  - Listing approved
  - Reservation expiring
  - New message
  - Document validation request
- In-app notifications
- Admin alerts for:
  - Pending validations
  - Expired timers
  - Reports

#### Interface
- Responsive web application
- Mobile-optimized views
- No native mobile app
- Consistent color scheme per user role
- Scrolling announcement banners

#### Analytics & Tracking
- View tracking per listing
- Favorite tracking
- Reservation tracking
- Abandonment tracking by stage
- Time-per-stage analytics
- Partner contact tracking
- User satisfaction tracking

---

## BRICK 2 - Advanced Features & Investment (€4500)

### Investor Profile (NEW)
- Register and browse investment opportunities
- View buyer financing requests
- Contact buyers seeking funds (simple matching, no transactions)

### Buyer (Additional Features)
- Post financing requests with deal details
- Receive investor contact requests
- Access 1h coaching (club membership)
- Request personalized sourcing (on-demand)

### Seller (Additional Features)
- Complete scorecard assessment
- View completeness score (star system)
- Track profile evolution

### Admin (Additional Features)
- Manage seller scorecards
- Configure top 5-10 deals of the month on homepage
- Configure weekly deal recaps
- Real-time push notifications for:
  - New listings to validate
  - Finalized deals

### System Features Brick 2
- Investment module (financing requests - matching only)
- Automated scorecard system for sellers
- Real-time web push notifications
- Automatic weekly email recaps (new validated deals)
- Gamification with credits
- Advanced analytics dashboard
- Semi-automated validation based on enrichment
- Favorites with availability alerts

---

## BRICK 3 - White-Label Crowdfunding Integration (€4500)

### Investor (Additional Features)
- Invest directly via secure iframe
- Track investments in dashboard
- View participation history

### Buyer (Additional Features)
- Launch fundraising campaign
- Track campaign progress in real-time
- Communicate with investors

### Admin (Additional Features)
- Track all active campaigns
- View global investment statistics
- Manage commissions on successful raises

### System Features Brick 3
- Widget/iframe integration with white-label platform (MIPISE or equivalent)
- Secure transaction system (AMF compliant)
- Fundraising campaign management
- Complete investor dashboard
- Automated commission system
- Advanced financial reporting
- Regulatory compliance (handled by white-label partner)

---

## Explicitly Excluded Features

### Brick 1:
- Native mobile applications (iOS/Android) - web app only
- Crowdfunding/fundraising with transactions
- Live chat/instant messaging (only async messages)
- Integrated video conferencing
- Advanced accounting features
- External CRM integration

### Brick 2:
- Financial transactions for investments (matching only)
- Advanced accounting management
- External CRM integration

### Brick 3:
- Crowdfunding platform development (white-label partner used)
- Regulatory compliance management (partner handles)

---

## Technical Requirements

### Frontend
- Responsive web design (mobile-first)
- Modern UI/UX following style guide
- French interface throughout
- Optimized for desktop, tablet, mobile browsers
- Turbo Streams for real-time features
- Stimulus for interactive elements (minimal usage)
- Tailwind CSS styling
- Lucide Icons

### Backend
- Ruby on Rails 8
- SQLite with Solid libraries
- RESTful API design
- Secure data handling
- Background jobs for notifications
- Email delivery system

### Integrations
- Stripe for payments
- Email delivery (transactional + marketing)
- Excel import/export
- External scorecard service (optional)
- White-label crowdfunding platform (Brick 3)

### Security
- GDPR compliance
- Secure authentication (Devise)
- Data encryption
- Electronic signature for NDAs
- Proof tracking for legal purposes
- IP address logging for signatures
- Audit trail for important actions

### Performance
- Fast page loads
- Optimized database queries
- Caching where appropriate
- Real-time updates via Turbo Streams (no polling)

---

## Data Requirements

### Industry Sectors (11 standard)
1. Industry
2. Construction (BTP)
3. Commerce & Distribution
4. Transport & Logistics
5. Hospitality / Restaurant
6. Services
7. Agri-food & Agriculture
8. Healthcare
9. Digital
10. Real Estate
11. Other

### CRM Stages (10 statuses)
1. Favorites
2. To Contact (7 days)
3. Info Exchange (33 days for stages 3-5)
4. Analysis
5. Project Alignment
6. Negotiation (20 days)
7. LOI (seller validation required)
8. Audits
9. Financing
10. Deal Signed

### Deal Types (3 types)
1. Direct Deal (seller-initiated)
2. Idéal Reprise Mandate (platform sourcing)
3. Partner Mandate (broker-initiated)

### Document Categories (11 types)
1. Balance Sheet N-1
2. Balance Sheet N-2
3. Balance Sheet N-3
4. Organization Chart
5. Tax Return
6. Income Statement
7. Vehicle/Heavy Equipment List
8. Lease Agreement
9. Property Title
10. Scorecard Report
11. Other (specify)

### Transfer Types
1. Asset sale (fond de commerce)
2. Partial share transfer
3. Total share transfer
4. Asset transfer

### Customer Types
1. B2B
2. B2C
3. Mixed

### Legal Forms
- SAS, SARL, SA, SCI, EURL, etc. (standard French legal forms)

---

## User Journeys

### Seller Journey
1. Register (free)
2. Create listing (public + confidential data)
3. Upload documents (11 categories)
4. Submit for validation
5. Wait for admin approval
6. Track views, favorites, interested buyers
7. Browse buyer directory
8. Push listings to matching buyers (credits)
9. Receive reservation notifications
10. Validate buyer enrichments
11. Communicate via messaging
12. Progress through CRM stages with buyer
13. Close deal

### Buyer Journey
1. Register
2. Create public/private profile
3. Browse listings (freemium)
4. Sign platform NDA
5. Subscribe to plan or buy credits
6. Favorite interesting listings
7. Reserve listing + sign listing-specific NDA
8. Access confidential data
9. Communicate with seller
10. Enrich listing with documents
11. Progress through CRM stages
12. Release or close deal
13. Earn credits for enrichments/releases

### Partner Journey
1. Register
2. Complete profile with coverage/specializations
3. Wait for admin validation
4. Pay annual directory subscription
5. Appear in directory
6. Receive contact requests
7. Track views and contacts
8. Renew subscription

### Admin Journey
1. Monitor operations dashboard (alerts)
2. Validate listings (+ optionally attribute deals)
3. Validate partners
4. Import leads from Excel
5. Assign exclusive deals
6. Send messages/surveys
7. Adjust platform settings
8. Monitor analytics
9. Review enrichments
10. Handle reports

---

## Success Metrics

### Platform Health
- Active listings ratio
- User satisfaction %
- Average time per CRM stage
- Deal completion rate
- Abandonment rate by stage

### User Engagement
- Listing views
- Favorites count
- Reservation rate
- Enrichment submissions
- Message volume
- Profile completeness

### Business Metrics
- Monthly recurring revenue
- Credit sales
- Subscription conversions
- Partner directory revenue
- Deal closure rate
- Commission revenue (Brick 3)

### Quality Metrics
- Listing completeness average
- Document upload rate
- NDA signing rate
- Buyer profile completeness
- Time to deal closure

---

## Notes

**Terminology:**
- Use "Repreneur" (not "Acheteur") throughout
- Use "Accord de confidentialité" (not just "NDA")
- Use "Mandat" for broker deals

**Design:**
- Consistent color scheme per role
- Professional, clean, modern aesthetic
- Mobile-first responsive design
- Scrolling announcement banners
- Progress gauges for timers
- Visual CRM pipeline

**Data Privacy:**
- Public data visible to all
- Confidential data only after NDA signing
- No identifiable information in public data
- Seller controls enrichment validation
- Message history for legal proof

---

Each brick is independent and optional. Client pays per brick delivered.
