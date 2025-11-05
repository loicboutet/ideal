# Data Models - Idéal Reprise

## Overview

This document defines the database models required for all 3 Bricks of the platform. All models follow Rails conventions and KISS principles.

**Note:** For mockups, these are documentation only. No actual migrations are created.

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
- has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
- has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id'
- has_many :conversations_as_participant

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
| is_broker | boolean | default: false | Is this a broker/partner seller |
| premium_access | boolean | default: false | Has paid for premium features |
| credits | integer | default: 0 | Available credits for pushing listings |
| free_contacts_used | integer | default: 0 | Count of free contacts used |
| free_contacts_limit | integer | default: 4 | Limit of free contacts |
| receive_signed_nda | boolean | default: true | Wants to receive signed NDAs |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- has_many :listings
- has_many :favorite_buyers (buyers who favorited their listings)

### Validations
- user_id: presence, uniqueness
- credits: numericality, greater_than_or_equal_to 0

---

## BuyerProfile Model

**Purpose:** Extended profile for buyers (repreneurs) with public/private data

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
| verified_buyer | boolean | default: false | Passed 30min audit (premium) |
| profile_status | enum | default: 'draft' | Profile publication status |
| completeness_score | integer | default: 0 | Profile completeness 0-100 |
| buyer_type | enum | optional | Type: individual, holding, fund, investor |
| formation | text | optional | Formation incl. business acquisition |
| experience | text | optional | Professional experience |
| skills | text | optional | Skills (max 200 chars) |
| investment_thesis | text | optional | Investment thesis (max 500 chars) |
| target_sectors | text | optional | JSON array of target sectors |
| target_locations | text | optional | JSON array of target locations |
| target_revenue_min | decimal | optional | Min target revenue |
| target_revenue_max | decimal | optional | Max target revenue |
| target_employees_min | integer | optional | Min target employees |
| target_employees_max | integer | optional | Max target employees |
| target_financial_health | enum | optional | in_bonis, in_difficulty, both |
| target_horizon | string | optional | Transfer horizon preference |
| target_transfer_types | text | optional | JSON array of transfer types |
| target_customer_types | text | optional | JSON array: B2B, B2C, mixed |
| investment_capacity | decimal | optional | Investment capacity |
| funding_sources | text | optional | Funding sources (max 200 chars) |
| linkedin_url | string | optional | LinkedIn profile (confidential) |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :user
- has_many :deals
- has_many :favorites
- has_many :enrichments
- has_many :favorited_by_sellers (sellers who favorited this buyer)

### Validations
- user_id: presence, uniqueness
- subscription_plan: inclusion in enum
- credits: numericality, greater_than_or_equal_to 0
- completeness_score: numericality, between 0-100
- buyer_type: inclusion in enum (if present)

### Enums
- subscription_plan: { free: 0, starter: 1, standard: 2, premium: 3, club: 4 }
  - starter: €89/month
  - standard: €199/month
  - premium: €249/month
  - club: €1200/year
- subscription_status: { inactive: 0, active: 1, cancelled: 2, expired: 3 }
- profile_status: { draft: 0, pending: 1, published: 2 }
- buyer_type: { individual: 0, holding: 1, fund: 2, investor: 3 }
- target_financial_health: { in_bonis: 0, in_difficulty: 1, both: 2 }

---

## PartnerProfile Model

**Purpose:** Extended profile for service partners

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| user_id | integer | FK, required, unique | Reference to User |
| partner_type | enum | required | Type: lawyer, accountant, consultant, banker, broker, other |
| description | text | optional | Company/service description |
| services_offered | text | optional | List of services |
| calendar_link | string | optional | Google Calendar booking link |
| website | string | optional | Partner website |
| coverage_area | enum | optional | City, department, region, nationwide, international |
| coverage_details | text | optional | Specific cities/departments if applicable |
| intervention_stages | text | optional | JSON array of CRM stages where partner intervenes |
| industry_specializations | text | optional | JSON array of specialized industries |
| validation_status | enum | default: 'pending' | Admin validation status |
| directory_subscription_expires_at | datetime | nullable | Directory subscription expiry |
| views_count | integer | default: 0 | Profile views counter |
| contacts_count | integer | default: 0 | Contact requests counter |
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
- partner_type: { lawyer: 0, accountant: 1, consultant: 2, banker: 3, broker: 4, other: 5 }
- validation_status: { pending: 0, approved: 1, rejected: 2 }
- coverage_area: { city: 0, department: 1, region: 2, nationwide: 3, international: 4 }

---

## Listing Model

**Purpose:** Business listings posted by sellers with public/confidential data

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| seller_profile_id | integer | FK, required | Reference to SellerProfile |
| deal_type | enum | default: 'direct' | Type: direct, ideal_mandate, partner_mandate |
| title | string | required | Generic business type (public) |
| description_public | text | optional | Public description |
| description_confidential | text | optional | Detailed description (confidential) |
| industry_sector | enum | required | One of 11 sectors |
| location_department | string | optional | Department (public) |
| location_city | string | optional | City (confidential) |
| location_region | string | optional | Region |
| location_country | string | default: 'France' | Country |
| annual_revenue | decimal | optional | CA (chiffre d'affaires) |
| employee_count | integer | optional | Number of employees |
| net_profit | decimal | optional | Bénéfices nets |
| asking_price | decimal | optional | Fixed asking price |
| price_min | decimal | optional | Minimum price range |
| price_max | decimal | optional | Maximum price range |
| transfer_horizon | string | optional | When seller wants to transfer |
| transfer_type | enum | optional | Asset sale, share transfer, etc. |
| company_age | integer | optional | Years in business |
| customer_type | enum | optional | B2B, B2C, mixed |
| legal_form | string | optional | SAS, SARL, etc. |
| website | string | optional | Company website (confidential) |
| net_revenue_ratio | decimal | optional | Net result / Revenue ratio |
| show_scorecard_stars | boolean | default: false | Display scorecard stars publicly |
| scorecard_stars | integer | optional | 0-5 stars from scorecard |
| validation_status | enum | default: 'pending' | Admin validation |
| status | enum | default: 'draft' | Listing status |
| completeness_score | integer | default: 0 | 0-100 score (60% listing, 40% docs) |
| views_count | integer | default: 0 | View counter |
| published_at | datetime | nullable | Publication date |
| attributed_buyer_id | integer | FK, nullable | Exclusive attribution (sourcing) |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :seller_profile
- belongs_to :attributed_buyer, class_name: 'BuyerProfile', optional: true
- has_one :seller_user, through: :seller_profile, source: :user
- has_many :deals
- has_many :favorites
- has_many :enrichments
- has_many :listing_documents
- has_many :listing_views

### Validations
- seller_profile_id: presence
- title: presence, length (3-200)
- industry_sector: inclusion in enum
- validation_status: inclusion in enum
- status: inclusion in enum
- deal_type: inclusion in enum
- annual_revenue: numericality (if present)
- employee_count: numericality, greater_than_or_equal_to 0 (if present)
- asking_price: numericality (if present)
- completeness_score: numericality, between 0-100

### Enums
- deal_type: { direct: 0, ideal_mandate: 1, partner_mandate: 2 }
- industry_sector: { 
    industry: 0, 
    construction: 1, 
    commerce: 2, 
    transport_logistics: 3, 
    hospitality: 4, 
    services: 5, 
    agrifood: 6, 
    healthcare: 7, 
    digital: 8, 
    real_estate: 9, 
    other: 10 
  }
- transfer_type: { asset_sale: 0, partial_shares: 1, total_shares: 2, assets: 3 }
- customer_type: { b2b: 0, b2c: 1, mixed: 2 }
- validation_status: { pending: 0, approved: 1, rejected: 2 }
- status: { draft: 0, published: 1, reserved: 2, in_negotiation: 3, sold: 4, withdrawn: 5 }

### Scopes
- approved: where(validation_status: :approved)
- published: where(status: :published)
- available: approved.published.where.not(status: [:reserved, :sold])
- with_deal_type: ->(type) { where(deal_type: type) }

---

## Deal Model

**Purpose:** Tracks buyer interest and CRM pipeline with 10 stages

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| buyer_profile_id | integer | FK, required | Reference to BuyerProfile |
| listing_id | integer | FK, required | Reference to Listing |
| status | enum | default: 'favorited' | Pipeline status (10 stages) |
| reserved | boolean | default: false | Is listing reserved by this buyer |
| reserved_at | datetime | nullable | Reservation timestamp |
| reserved_until | datetime | nullable | Reservation expiry |
| stage_entered_at | datetime | nullable | When entered current stage |
| time_in_stage | integer | default: 0 | Seconds in current stage |
| total_credits_earned | integer | default: 0 | Credits earned from this deal |
| loi_seller_validated | boolean | default: false | Seller validated LOI stage |
| notes | text | optional | Buyer's private notes |
| released_at | datetime | nullable | When deal was released |
| release_reason | text | optional | Why deal was released |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :buyer_profile
- belongs_to :listing
- has_one :buyer_user, through: :buyer_profile, source: :user
- has_many :deal_history_events

### Validations
- buyer_profile_id: presence
- listing_id: presence
- status: inclusion in enum
- Unique combination of buyer_profile_id and listing_id (unless released)

### Enums
- status: { 
    favorited: 0,
    to_contact: 1,
    info_exchange: 2,
    analysis: 3,
    project_alignment: 4,
    negotiation: 5,
    loi: 6,
    audits: 7,
    financing: 8,
    signed: 9,
    released: 10,
    abandoned: 11
  }

### Timer Logic
- to_contact: 7 days
- info_exchange + analysis + project_alignment: 33 days total
- negotiation: 20 days
- loi: No timer (waiting seller validation)
- audits, financing, signed: No timer

### Callbacks
- After create: send notification to seller (if reserved)
- After update (if status changes): 
  - Update listing status if needed
  - Create deal_history_event
  - Calculate time_in_stage
  - Extend or pause timer based on stage
- After release: 
  - Calculate credits earned
  - Update listing status
  - Send notifications

---

## DealHistoryEvent Model

**Purpose:** Track all movements and actions on a deal

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| deal_id | integer | FK, required | Reference to Deal |
| event_type | enum | required | Type of event |
| from_status | enum | nullable | Previous status |
| to_status | enum | nullable | New status |
| notes | text | optional | Event notes |
| user_id | integer | FK, nullable | User who triggered event |
| created_at | datetime | auto | Event timestamp |

### Relationships
- belongs_to :deal
- belongs_to :user, optional: true

### Validations
- deal_id: presence
- event_type: inclusion in enum

### Enums
- event_type: { 
    status_change: 0, 
    document_added: 1, 
    message_sent: 2, 
    reservation: 3, 
    release: 4,
    timer_extended: 5,
    loi_validated: 6
  }

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

**Purpose:** Track buyer contributions to listings (validated by seller)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| buyer_profile_id | integer | FK, required | Reference to BuyerProfile |
| listing_id | integer | FK, required | Reference to Listing |
| document_category | enum | required | Category of document added |
| description | text | optional | Description of contribution |
| credits_awarded | integer | default: 0 | Credits given (1 per category) |
| validated | boolean | default: false | Seller approved |
| validated_at | datetime | nullable | Validation timestamp |
| validated_by_id | integer | FK, nullable | Seller user who validated |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :buyer_profile
- belongs_to :listing
- belongs_to :validated_by, class_name: 'User', optional: true

### Validations
- buyer_profile_id: presence
- listing_id: presence
- document_category: inclusion in enum
- credits_awarded: numericality, greater_than_or_equal_to 0

### Enums
- document_category: {
    balance_n1: 0,
    balance_n2: 1,
    balance_n3: 2,
    org_chart: 3,
    tax_return: 4,
    income_statement: 5,
    vehicle_list: 6,
    lease: 7,
    property_title: 8,
    scorecard: 9,
    other: 10
  }

---

## ListingDocument Model

**Purpose:** Store documents attached to listings (11 categories)

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| listing_id | integer | FK, required | Reference to Listing |
| uploaded_by_id | integer | FK, required | User who uploaded |
| document_category | enum | required | One of 11 categories |
| title | string | required | Document title |
| description | text | optional | Document description |
| file_name | string | required | Original filename |
| file_path | string | required | Storage path |
| file_size | integer | required | File size in bytes |
| content_type | string | required | MIME type |
| not_applicable | boolean | default: false | N/A checkbox |
| nda_required | boolean | default: true | Requires NDA to view |
| validated_by_seller | boolean | default: true | Seller validation (false if buyer-added) |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :listing
- belongs_to :uploaded_by, class_name: 'User'

### Validations
- listing_id: presence
- uploaded_by_id: presence
- document_category: inclusion in enum
- title: presence
- file_name: presence
- file_path: presence

### Enums
- document_category: {
    balance_n1: 0,
    balance_n2: 1,
    balance_n3: 2,
    org_chart: 3,
    tax_return: 4,
    income_statement: 5,
    vehicle_list: 6,
    lease: 7,
    property_title: 8,
    scorecard: 9,
    other: 10
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

## Message Model (NEW - Brick 1)

**Purpose:** Internal messaging system between users

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| conversation_id | integer | FK, required | Reference to Conversation |
| sender_id | integer | FK, required | User who sent message |
| body | text | required | Message content |
| read | boolean | default: false | Read status |
| read_at | datetime | nullable | When message was read |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :conversation
- belongs_to :sender, class_name: 'User'

### Validations
- conversation_id: presence
- sender_id: presence
- body: presence, length (1-5000)

### Callbacks
- After create: 
  - Send email notification to recipient
  - Broadcast via Turbo Stream for real-time update
  - Create notification record

---

## Conversation Model (NEW - Brick 1)

**Purpose:** Groups messages between users

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| listing_id | integer | FK, nullable | Related listing (if applicable) |
| subject | string | optional | Conversation subject |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :listing, optional: true
- has_many :messages, dependent: :destroy
- has_many :conversation_participants
- has_many :participants, through: :conversation_participants, source: :user

### Validations
- At least 2 participants required

---

## ConversationParticipant Model (NEW - Brick 1)

**Purpose:** Join table for conversation participants

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| conversation_id | integer | FK, required | Reference to Conversation |
| user_id | integer | FK, required | Reference to User |
| last_read_at | datetime | nullable | Last time user read messages |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :conversation
- belongs_to :user

### Validations
- conversation_id: presence
- user_id: presence
- Unique combination of conversation_id and user_id

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
    buyer_starter: 1, 
    buyer_standard: 2, 
    buyer_premium: 3, 
    buyer_club: 4, 
    partner_directory: 5,
    credit_pack_small: 6,
    credit_pack_medium: 7,
    credit_pack_large: 8
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
    new_message: 7,
    deal_status_changed: 8,
    document_validation_request: 9,
    listing_pushed: 10,
    buyer_interested: 11,
    timer_expired: 12,
    loi_validation_request: 13
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

## ListingView Model (NEW)

**Purpose:** Track who viewed which listings

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| listing_id | integer | FK, required | Reference to Listing |
| user_id | integer | FK, nullable | User who viewed (null if anonymous) |
| ip_address | string | optional | Viewer IP |
| viewed_at | datetime | required | View timestamp |
| created_at | datetime | auto | Creation timestamp |

### Relationships
- belongs_to :listing
- belongs_to :user, optional: true

### Validations
- listing_id: presence
- viewed_at: presence

---

## PartnerContact Model (NEW)

**Purpose:** Track partner contact requests

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| partner_profile_id | integer | FK, required | Reference to PartnerProfile |
| user_id | integer | FK, required | User who contacted |
| contact_type | enum | required | View or direct contact |
| created_at | datetime | auto | Creation timestamp |

### Relationships
- belongs_to :partner_profile
- belongs_to :user

### Validations
- partner_profile_id: presence
- user_id: presence
- contact_type: inclusion in enum

### Enums
- contact_type: { view: 0, contact: 1 }

---

## Questionnaire Model (NEW - for admin)

**Purpose:** Satisfaction surveys and development questionnaires

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| title | string | required | Questionnaire title |
| description | text | optional | Description |
| questionnaire_type | enum | required | Satisfaction or development |
| questions | text | required | JSON array of questions |
| target_role | enum | nullable | Target user role (null = all) |
| active | boolean | default: true | Is questionnaire active |
| created_by_id | integer | FK, required | Admin who created |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Relationships
- belongs_to :created_by, class_name: 'User'
- has_many :questionnaire_responses

### Validations
- title: presence
- questionnaire_type: inclusion in enum
- questions: presence

### Enums
- questionnaire_type: { satisfaction: 0, development: 1 }
- target_role: { all: 0, seller: 1, buyer: 2, partner: 3 }

---

## QuestionnaireResponse Model (NEW)

**Purpose:** User responses to questionnaires

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| questionnaire_id | integer | FK, required | Reference to Questionnaire |
| user_id | integer | FK, required | User who responded |
| answers | text | required | JSON of answers |
| completed_at | datetime | required | Response timestamp |
| created_at | datetime | auto | Creation timestamp |

### Relationships
- belongs_to :questionnaire
- belongs_to :user

### Validations
- questionnaire_id: presence
- user_id: presence
- answers: presence

---

## PlatformSettings Model (NEW - for admin)

**Purpose:** Configurable platform settings

### Attributes

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | integer | PK, auto | Primary key |
| setting_key | string | required, unique | Setting identifier |
| setting_value | text | required | Setting value (JSON if needed) |
| setting_type | enum | required | String, integer, boolean, json |
| description | text | optional | Setting description |
| updated_by_id | integer | FK, nullable | Admin who last updated |
| created_at | datetime | auto | Creation timestamp |
| updated_at | datetime | auto | Update timestamp |

### Validations
- setting_key: presence, uniqueness
- setting_value: presence
- setting_type: inclusion in enum

### Enums
- setting_type: { string: 0, integer: 1, boolean: 2, json: 3, decimal: 4 }

### Default Settings
- timer_to_contact_days: 7
- timer_middle_stages_days: 33
- timer_negotiation_days: 20
- seller_free_contacts: 4
- seller_credit_price: TBD
- buyer_starter_price: 89.00
- buyer_standard_price: 199.00
- buyer_premium_price: 249.00
- buyer_club_price: 1200.00
- partner_directory_price: TBD
- credit_per_document: 1
- credit_per_release: 1

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
    listing_rejected: 4,
    deal_created: 5,
    deal_updated: 6,
    deal_released: 7,
    nda_signed: 8,
    payment_processed: 9,
    import_completed: 10,
    message_sent: 11,
    document_uploaded: 12,
    enrichment_submitted: 13,
    settings_updated: 14
  }

---

## Summary Statistics

**Total Models:** 23 core models (3 new for messaging, 6 new for features)

**New Models (vs original):**
- Message
- Conversation
- ConversationParticipant
- ListingView
- PartnerContact
- DealHistoryEvent
- Questionnaire
- QuestionnaireResponse
- PlatformSettings

**Relationships Summary:**
- User → SellerProfile (1:1)
- User → BuyerProfile (1:1) - **now with public/private data**
- User → PartnerProfile (1:1)
- User → Messages (1:many as sender/recipient)
- User → Conversations (many:many through participants)
- SellerProfile → Listings (1:many)
- Listing → Deals (1:many)
- Listing → Favorites (1:many)
- Listing → Enrichments (1:many)
- Listing → ListingDocuments (1:many)
- Listing → ListingViews (1:many)
- BuyerProfile → Deals (1:many)
- BuyerProfile → Favorites (1:many)
- PartnerProfile → PartnerContacts (1:many)
- Deal → DealHistoryEvents (1:many)
- Conversation → Messages (1:many)
- User → NdaSignatures (1:many)
- User → Subscriptions (1:many)
- User → Notifications (1:many)
- User → QuestionnaireResponses (1:many)

---

## Implementation Notes

1. **No actual migrations needed for mockups** - This is for documentation only
2. All timestamps use Rails conventions (created_at, updated_at)
3. All enums use integer backing (Rails standard)
4. Foreign keys use `_id` suffix
5. Polymorphic relationships use `_type` and `_id` columns
6. Soft deletes not implemented (can be added later)
7. All decimal fields use precision: 15, scale: 2 by default
8. JSON fields for metadata/flexibility where needed
9. Messaging system designed for Turbo Streams real-time updates
10. Timer logic handled in application layer, not database constraints
11. Completeness scores calculated dynamically but cached in model

---

## Database Indexes (for production)

Key indexes to add:
- user_id on all profile tables
- listing_id on deals, favorites, enrichments, documents, views
- buyer_profile_id on deals, favorites
- seller_profile_id on listings
- conversation_id on messages
- validation_status on listings, partner_profiles
- status on listings, deals, subscriptions
- deal_type on listings
- industry_sector on listings
- stripe_customer_id on buyer_profiles, partner_profiles
- email on users (unique)
- setting_key on platform_settings (unique)
- Composite indexes on favorites (profile_id + listing_id)
- Composite indexes on deals (profile_id + listing_id)
- Composite indexes on conversation_participants (conversation_id + user_id)
- created_at on most tables for time-based queries
- read/read_at on messages and notifications

---

## Data Migration Notes

When moving from mockups to production:
1. User model already exists (Devise)
2. Create profile models first
3. Create listing model
4. Create deal/favorite/enrichment models
5. Create document models
6. Create messaging models
7. Create notification models
8. Create platform settings with defaults
9. Populate industry sectors and other enums
10. Create admin user
11. Set up Stripe webhooks
12. Configure email delivery
13. Set up Turbo Streams for real-time messaging
