# Data Models - Idéal Reprise

## Overview

This document defines the database models required for Brick 1 of the platform. All models follow Rails conventions and KISS principles.

---

## User Model

**Purpose:** Base authentication and authorization for all user types

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| email | string | required, unique | User email (login) |
| encrypted_password | string | required | Devise encrypted password |
| role | enum | required | User type: admin, seller, buyer, partner |
| first_name | string | optional | User first name |
| last_name | string | optional | User last name |
| phone | string | optional | Contact phone |
| company_name | string | optional | Company name |
| status | enum | default: 'active' | Account status: active, suspended, pending |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |
| reset_password_token | string | indexed | Devise reset token |
| reset_password_sent_at | datetime | | Devise reset timestamp |
| remember_created_at | datetime | | Devise remember me |
| sign_in_count | integer | default: 0 | Devise tracking |
| current_sign_in_at | datetime | | Devise tracking |
| last_sign_in_at | datetime | | Devise tracking |
| current_sign_in_ip | string | | Devise tracking |
| last_sign_in_ip | string | | Devise tracking |

### Relationships
- has_one :seller_profile (if role is seller)
- has_one :buyer_profile (if role is buyer)
- has_one :partner_profile (if role is partner)
- has_many :listings (as seller, through seller_profile)
- has_many :deals (as buyer, through buyer_profile)
- has_many :nda_signatures

### Validations
- email: presence, uniqueness, format
- role: presence, inclusion in enum
- password: presence (on create), length

### Enums
- role: { admin: 0, seller: 1, buyer: 2, partner: 3 }
- status: { pending: 0, active: 1, suspended: 2 }

---

## SellerProfile Model

**Purpose:** Extended profile for sellers (cédants)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required, unique | Reference to User |
| premium_access | boolean | default: false | Has paid for premium features |
| free_contacts_used | integer | default: 0 | Count of free contacts used |
| free_contacts_limit | integer | default: 4 | Limit of free contacts |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- has_many :listings

### Validations
- user_id: presence, uniqueness

---

## BuyerProfile Model

**Purpose:** Extended profile for buyers (repreneurs)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required, unique | Reference to User |
| subscription_plan | enum | default: 'free' | Subscription level |
| subscription_status | enum | default: 'inactive' | Status: active, inactive, cancelled |
| subscription_expires_at | datetime | nullable | Subscription expiry date |
| credits | integer | default: 0 | Available credits |
| stripe_customer_id | string | indexed | Stripe customer ID |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- has_many :deals
- has_many :favorites
- has_many :enrichments

### Validations
- user_id: presence, uniqueness
- subscription_plan: inclusion in enum
- credits: numericality, greater_than_or_equal_to 0

### Enums
- subscription_plan: { free: 0, basic: 1, standard: 2, premium: 3, club: 4 }
  - basic: €89/month
  - standard: €199/month
  - premium: €249/month
  - club: €1200/year
- subscription_status: { inactive: 0, active: 1, cancelled: 2, expired: 3 }

---

## PartnerProfile Model

**Purpose:** Extended profile for service partners

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required, unique | Reference to User |
| partner_type | enum | required | Type: lawyer, accountant, consultant, other |
| description | text | optional | Company/service description |
| services_offered | text | optional | List of services |
| calendar_link | string | optional | Google Calendar booking link |
| website | string | optional | Partner website |
| validation_status | enum | default: 'pending' | Admin validation status |
| directory_subscription_expires_at | datetime | nullable | Directory subscription expiry |
| stripe_customer_id | string | indexed | Stripe customer ID |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user

### Validations
- user_id: presence, uniqueness
- partner_type: presence, inclusion in enum
- validation_status: inclusion in enum
- website: url format (if present)
- calendar_link: url format (if present)

### Enums
- partner_type: { lawyer: 0, accountant: 1, consultant: 2, banker: 3, other: 4 }
- validation_status: { pending: 0, approved: 1, rejected: 2 }

---

## Listing Model

**Purpose:** Business listings posted by sellers

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| seller_profile_id | integer | FK, required | Reference to SellerProfile |
| title | string | required | Listing title |
| description | text | optional | Business description |
| annual_revenue | decimal | optional | CA (chiffre d'affaires) |
| employee_count | integer | optional | Number of employees |
| net_profit | decimal | optional | Bénéfices nets |
| asking_price | decimal | optional | Fixed asking price |
| price_min | decimal | optional | Minimum price range |
| price_max | decimal | optional | Maximum price range |
| location_city | string | optional | City location |
| location_region | string | optional | Region/department |
| location_country | string | default: 'France' | Country |
| industry | string | optional | Business sector |
| validation_status | enum | default: 'pending' | Admin validation |
| status | enum | default: 'draft' | Listing status |
| completeness_score | integer | default: 0 | 0-100 score |
| views_count | integer | default: 0 | View counter |
| published_at | datetime | nullable | Publication date |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :seller_profile
- has_one :seller_user, through: :seller_profile, source: :user
- has_many :deals
- has_many :favorites
- has_many :enrichments
- has_many :listing_documents

### Validations
- seller_profile_id: presence
- title: presence, length (3-200)
- validation_status: inclusion in enum
- status: inclusion in enum
- annual_revenue: numericality (if present)
- employee_count: numericality, greater_than_or_equal_to 0 (if present)
- asking_price: numericality (if present)
- completeness_score: numericality, between 0-100

### Enums
- validation_status: { pending: 0, approved: 1, rejected: 2 }
- status: { draft: 0, published: 1, reserved: 2, in_negotiation: 3, sold: 4, withdrawn: 5 }

### Scopes
- approved: where(validation_status: :approved)
- published: where(status: :published)
- available: approved.published.where.not(status: [:reserved, :sold])

---

## Deal Model

**Purpose:** Tracks buyer interest and CRM pipeline

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| buyer_profile_id | integer | FK, required | Reference to BuyerProfile |
| listing_id | integer | FK, required | Reference to Listing |
| status | enum | default: 'to_contact' | Pipeline status |
| reserved | boolean | default: false | Is listing reserved by this buyer |
| reserved_at | datetime | nullable | Reservation timestamp |
| reserved_until | datetime | nullable | Reservation expiry |
| notes | text | optional | Buyer's private notes |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :buyer_profile
- belongs_to :listing
- has_one :buyer_user, through: :buyer_profile, source: :user

### Validations
- buyer_profile_id: presence
- listing_id: presence
- status: inclusion in enum
- Unique combination of buyer_profile_id and listing_id

### Enums
- status: { 
    to_contact: 0, 
    in_relationship: 1, 
    under_study: 2, 
    negotiations: 3, 
    signed: 4, 
    finalized: 5,
    abandoned: 6
  }

### Callbacks
- After create: send notification to seller
- After update (if status changes): update listing status if needed
- After destroy: release reservation if active

---

## Favorite Model

**Purpose:** Buyers can favorite listings (watchlist)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| buyer_profile_id | integer | FK, required | Reference to BuyerProfile |
| listing_id | integer | FK, required | Reference to Listing |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :buyer_profile
- belongs_to :listing

### Validations
- buyer_profile_id: presence
- listing_id: presence
- Unique combination of buyer_profile_id and listing_id

---

## Enrichment Model

**Purpose:** Track buyer contributions to listings (for credits)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| buyer_profile_id | integer | FK, required | Reference to BuyerProfile |
| listing_id | integer | FK, required | Reference to Listing |
| enrichment_type | enum | required | Type of enrichment |
| description | text | optional | Description of contribution |
| credits_awarded | integer | default: 0 | Credits given |
| validated | boolean | default: false | Admin approved |
| validated_at | datetime | nullable | Validation timestamp |
| validated_by_id | integer | FK, nullable | Admin user who validated |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :buyer_profile
- belongs_to :listing
- belongs_to :validated_by, class_name: 'User', optional: true

### Validations
- buyer_profile_id: presence
- listing_id: presence
- enrichment_type: inclusion in enum
- credits_awarded: numericality, greater_than_or_equal_to 0

### Enums
- enrichment_type: { 
    financial_documents: 0, 
    market_analysis: 1, 
    additional_info: 2, 
    photos: 3, 
    other: 4 
  }

---

## ListingDocument Model

**Purpose:** Store documents attached to listings

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| listing_id | integer | FK, required | Reference to Listing |
| uploaded_by_id | integer | FK, required | User who uploaded |
| document_type | enum | required | Type of document |
| title | string | required | Document title |
| description | text | optional | Document description |
| file_name | string | required | Original filename |
| file_path | string | required | Storage path |
| file_size | integer | required | File size in bytes |
| content_type | string | required | MIME type |
| nda_required | boolean | default: true | Requires NDA to view |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :listing
- belongs_to :uploaded_by, class_name: 'User'

### Validations
- listing_id: presence
- uploaded_by_id: presence
- document_type: inclusion in enum
- title: presence
- file_name: presence
- file_path: presence

### Enums
- document_type: { 
    financial_statement: 0, 
    balance_sheet: 1, 
    legal_document: 2, 
    photo: 3, 
    presentation: 4, 
    other: 5 
  }

---

## NdaSignature Model

**Purpose:** Track NDA signatures by buyers

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required | Reference to User (buyer) |
| listing_id | integer | FK, nullable | Specific listing (if applicable) |
| signature_type | enum | required | Platform-wide or listing-specific |
| signed_at | datetime | required | Signature timestamp |
| ip_address | string | required | Signer IP address |
| user_agent | string | optional | Browser info |
| accepted_terms | boolean | default: true | Acceptance confirmation |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- belongs_to :listing, optional: true

### Validations
- user_id: presence
- signature_type: inclusion in enum
- signed_at: presence
- ip_address: presence

### Enums
- signature_type: { platform_wide: 0, listing_specific: 1 }

---

## Subscription Model

**Purpose:** Track payment history and subscriptions

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required | Reference to User |
| profile_type | string | required | SellerProfile, BuyerProfile, or PartnerProfile |
| profile_id | integer | FK, required | Polymorphic profile ID |
| stripe_subscription_id | string | indexed | Stripe subscription ID |
| plan_type | enum | required | Subscription plan |
| amount | decimal | required | Amount paid |
| currency | string | default: 'EUR' | Currency code |
| status | enum | required | Payment/subscription status |
| period_start | datetime | required | Billing period start |
| period_end | datetime | required | Billing period end |
| cancelled_at | datetime | nullable | Cancellation date |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- belongs_to :profile, polymorphic: true

### Validations
- user_id: presence
- profile_type: presence
- profile_id: presence
- plan_type: inclusion in enum
- amount: presence, numericality
- status: inclusion in enum
- period_start: presence
- period_end: presence

### Enums
- plan_type: { 
    seller_premium: 0, 
    buyer_basic: 1, 
    buyer_standard: 2, 
    buyer_premium: 3, 
    buyer_club: 4, 
    partner_directory: 5 
  }
- status: { pending: 0, active: 1, cancelled: 2, expired: 3, failed: 4 }

---

## Notification Model

**Purpose:** System notifications for users

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required | Reference to User |
| notification_type | enum | required | Type of notification |
| title | string | required | Notification title |
| message | text | required | Notification message |
| link_url | string | optional | Associated URL |
| read | boolean | default: false | Read status |
| read_at | datetime | nullable | Read timestamp |
| sent_via_email | boolean | default: false | Email sent |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user

### Validations
- user_id: presence
- notification_type: inclusion in enum
- title: presence
- message: presence

### Enums
- notification_type: { 
    new_deal: 0, 
    listing_validated: 1, 
    listing_rejected: 2,
    favorite_available: 3, 
    reservation_expiring: 4,
    subscription_expiring: 5,
    enrichment_validated: 6,
    new_message: 7
  }

---

## LeadImport Model

**Purpose:** Track bulk imports from Excel

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| imported_by_id | integer | FK, required | Admin who imported |
| file_name | string | required | Original Excel filename |
| total_rows | integer | required | Total rows in file |
| successful_imports | integer | default: 0 | Successfully imported |
| failed_imports | integer | default: 0 | Failed imports |
| import_status | enum | default: 'pending' | Import status |
| error_log | text | optional | Error details |
| completed_at | datetime | nullable | Completion timestamp |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :imported_by, class_name: 'User'
- has_many :imported_listings

### Validations
- imported_by_id: presence
- file_name: presence
- total_rows: presence, numericality
- import_status: inclusion in enum

### Enums
- import_status: { pending: 0, processing: 1, completed: 2, failed: 3 }

---

## Activity Model (Optional - for audit trail)

**Purpose:** Log important user actions for admin review

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, nullable | User who performed action |
| action_type | enum | required | Type of action |
| trackable_type | string | nullable | Polymorphic type |
| trackable_id | integer | FK, nullable | Polymorphic ID |
| metadata | json | optional | Additional data |
| ip_address | string | optional | User IP |
| created_at | datetime | auto | Creation timestamp |

### Relationships
- belongs_to :user, optional: true
- belongs_to :trackable, polymorphic: true, optional: true

### Validations
- action_type: inclusion in enum

### Enums
- action_type: { 
    user_created: 0, 
    user_updated: 1,
    listing_created: 2, 
    listing_validated: 3,
    deal_created: 4,
    deal_updated: 5,
    nda_signed: 6,
    payment_processed: 7,
    import_completed: 8
  }

---

## Summary Statistics

**Total Models:** 15 core models

**Relationships Summary:**
- User → SellerProfile (1:1)
- User → BuyerProfile (1:1)
- User → PartnerProfile (1:1)
- SellerProfile → Listings (1:many)
- Listing → Deals (1:many)
- Listing → Favorites (1:many)
- Listing → Enrichments (1:many)
- Listing → ListingDocuments (1:many)
- BuyerProfile → Deals (1:many)
- BuyerProfile → Favorites (1:many)
- User → NdaSignatures (1:many)
- User → Subscriptions (1:many)
- User → Notifications (1:many)

---

## Implementation Notes

1. **No actual migrations needed for mockups** - This is for documentation only
2. All timestamps use Rails conventions (created_at, updated_at)
3. All enums use integer backing (Rails standard)
4. Foreign keys use `_id` suffix
5. Polymorphic relationships use `_type` and `_id` columns
6. Soft deletes not implemented in Brick 1 (can be added later)
7. All decimal fields use precision: 15, scale: 2 by default
8. JSON fields for metadata/flexibility where needed

---

## Database Indexes (for production)

Key indexes to add:
- user_id on all profile tables
- listing_id on deals, favorites, enrichments
- buyer_profile_id on deals, favorites
- validation_status on listings
- status on listings, deals
- stripe_customer_id on buyer_profiles, partner_profiles
- email on users (unique)
- Composite indexes on favorites and deals (profile_id + listing_id)
