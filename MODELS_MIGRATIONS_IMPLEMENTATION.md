# Complete Models and Migrations Implementation Guide

This document contains the complete implementation for all remaining migrations and models based on specifications.md and models.md.

## Status Summary

### Completed ✅
1. User model - Enhanced with role, status, tracking
2. SellerProfile - Migration + Model
3. BuyerProfile - Migration + Model  
4. PartnerProfile - Migration + Model
5. Listing - Migration created
6. Deal - Migration created

### To Complete 📝
- All other migrations need to be filled in
- All model files need to be created
- See complete implementations below

---

## Remaining Migrations

### 1. CreateFavorites (20251118040814_create_favorites.rb)

```ruby
class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :favorites, [:buyer_profile_id, :listing_id], unique: true
  end
end
```

### 2. CreateDealHistoryEvents (20251118040815_create_deal_history_events.rb)

```ruby
class CreateDealHistoryEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :deal_history_events do |t|
      t.references :deal, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      
      t.integer :event_type, null: false
      t.integer :from_status
      t.integer :to_status
      t.text :notes

      t.timestamps
    end
    
    add_index :deal_history_events, :event_type
    add_index :deal_history_events, :created_at
  end
end
```

### 3. CreateListingDocuments (20251118040841_create_listing_documents.rb)

```ruby
class CreateListingDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_documents do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      
      t.integer :document_category, null: false
      t.string :title, null: false
      t.text :description
      t.string :file_name, null: false
      t.string :file_path, null: false
      t.integer :file_size, null: false
      t.string :content_type, null: false
      t.boolean :not_applicable, default: false, null: false
      t.boolean :nda_required, default: true, null: false
      t.boolean :validated_by_seller, default: true, null: false

      t.timestamps
    end
    
    add_index :listing_documents, :document_category
    add_index :listing_documents, [:listing_id, :document_category]
  end
end
```

### 4. CreateEnrichments (20251118040842_create_enrichments.rb)

```ruby
class CreateEnrichments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrichments do |t|
      t.references :buyer_profile, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.references :validated_by, null: true, foreign_key: { to_table: :users }
      
      t.integer :document_category, null: false
      t.text :description
      t.integer :credits_awarded, default: 0, null: false
      t.boolean :validated, default: false, null: false
      t.datetime :validated_at

      t.timestamps
    end
    
    add_index :enrichments, :validated
    add_index :enrichments, [:listing_id,  :buyer_profile_id]
  end
end
```

### 5. CreateConversations (20251118040843_create_conversations.rb)

```ruby
class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :listing, null: true, foreign_key: true
      t.string :subject

      t.timestamps
    end
    
    add_index :conversations, :listing_id
  end
end
```

### 6. CreateConversationParticipants (20251118040844_create_conversation_participants.rb)

```ruby
class CreateConversationParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at

      t.timestamps
    end
    
    add_index :conversation_participants, [:conversation_id, :user_id], unique: true, name: 'index_conv_participants_on_conv_and_user'
  end
end
```

### 7. CreateMessages (20251118040845_create_messages.rb)

```ruby
class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      
      t.text :body, null: false
      t.boolean :read, default: false, null: false
      t.datetime :read_at

      t.timestamps
    end
    
    add_index :messages, :read
    add_index :messages, :created_at
  end
end
```

### 8. CreateNdaSignatures (20251118040930_create_nda_signatures.rb)

```ruby
class CreateNdaSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :nda_signatures do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: true, foreign_key: true
      
      t.integer :signature_type, null: false
      t.datetime :signed_at, null: false
      t.string :ip_address, null: false
      t.string :user_agent
      t.boolean :accepted_terms, default: true, null: false

      t.timestamps
    end
    
    add_index :nda_signatures, :signature_type
    add_index :nda_signatures, :signed_at
    add_index :nda_signatures, [:user_id, :listing_id]
  end
end
```

### 9. CreateSubscriptions (20251118040931_create_subscriptions.rb)

```ruby
class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :profile, polymorphic: true, null: false
      
      t.string :stripe_subscription_id
      t.integer :plan_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'EUR', null: false
      t.integer :status, null: false
      t.datetime :period_start, null: false
      t.datetime :period_end, null: false
      t.datetime :cancelled_at

      t.timestamps
    end
    
    add_index :subscriptions, :stripe_subscription_id
    add_index :subscriptions, :status
    add_index :subscriptions, [:profile_type, :profile_id]
  end
end
```

### 10. CreateNotifications (20251118040932_create_notifications.rb)

```ruby
class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      
      t.integer :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.string :link_url
      t.boolean :read, default: false, null: false
      t.datetime :read_at
      t.boolean :sent_via_email, default: false, null: false

      t.timestamps
    end
    
    add_index :notifications, :notification_type
    add_index :notifications, :read
    add_index :notifications, :created_at
  end
end
```

### 11. CreateListingViews (20251118040933_create_listing_views.rb)

```ruby
class CreateListingViews < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_views do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      
      t.string :ip_address
      t.datetime :viewed_at, null: false

      t.timestamps
    end
    
    add_index :listing_views, :viewed_at
    add_index :listing_views, [:listing_id, :user_id]
  end
end
```

### 12. CreatePartnerContacts (20251118040934_create_partner_contacts.rb)

```ruby
class CreatePartnerContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :partner_contacts do |t|
      t.references :partner_profile, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.integer :contact_type, null: false

      t.timestamps
    end
    
    add_index :partner_contacts, :contact_type
    add_index :partner_contacts, :created_at
  end
end
```

### 13. CreatePlatformSettings (20251118040951_create_platform_settings.rb)

```ruby
class CreatePlatformSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :platform_settings do |t|
      t.string :setting_key, null: false
      t.text :setting_value, null: false
      t.integer :setting_type, null: false
      t.text :description
      t.references :updated_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :platform_settings, :setting_key, unique: true
  end
end
```

### 14. CreateQuestionnaires (20251118040952_create_questionnaires.rb)

```ruby
class CreateQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaires do |t|
      t.string :title, null: false
      t.text :description
      t.integer :questionnaire_type, null: false
      t.text :questions, null: false
      t.integer :target_role
      t.boolean :active, default: true, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :questionnaires, :questionnaire_type
    add_index :questionnaires, :active
  end
end
```

### 15. CreateQuestionnaireResponses (20251118040953_create_questionnaire_responses.rb)

```ruby
class CreateQuestionnaireResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaire_responses do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      
      t.text :answers, null: false
      t.datetime :completed_at, null: false

      t.timestamps
    end
    
    add_index :questionnaire_responses, [:questionnaire_id, :user_id]
  end
end
```

### 16. CreateLeadImports (20251118040954_create_lead_imports.rb)

```ruby
class CreateLeadImports < ActiveRecord::Migration[8.0]
  def change
    create_table :lead_imports do |t|
      t.references :imported_by, null: false, foreign_key: { to_table: :users }
      
      t.string :file_name, null: false
      t.integer :total_rows, null: false
      t.integer :successful_imports, default: 0, null: false
      t.integer :failed_imports, default: 0, null: false
      t.integer :import_status, default: 0, null: false
      t.text :error_log
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :lead_imports, :import_status
  end
end
```

### 17. CreateActivities (20251118040955_create_activities.rb)

```ruby
class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: true, foreign_key: true
      t.references :trackable, polymorphic: true, null: true
      
      t.integer :action_type, null: false
      t.json :metadata
      t.string :ip_address

      t.timestamps
    end
    
    add_index :activities, :action_type
    add_index :activities, :created_at
    add_index :activities, [:trackable_type, :trackable_id]
  end
end
```

---

## Remaining Model Files

### listing.rb

```ruby
class Listing < ApplicationRecord
  belongs_to :seller_profile
  belongs_to :attributed_buyer, class_name: 'BuyerProfile', optional: true
  
  has_many :deals, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :enrichments, dependent: :destroy
  has_many :listing_documents, dependent: :destroy
  has_many :listing_views, dependent: :destroy
  has_many :conversations, dependent: :nullify
  
  # Enums
  enum deal_type: { direct: 0, ideal_mandate: 1, partner_mandate: 2 }
  enum industry_sector: { 
    industry: 0, construction: 1, commerce: 2, transport_logistics: 3,
    hospitality: 4, services: 5, agrifood: 6, healthcare: 7,
    digital: 8, real_estate: 9, other: 10
  }
  enum transfer_type: { asset_sale: 0, partial_shares: 1, total_shares: 2, assets: 3 }
  enum customer_type: { b2b: 0, b2c: 1, mixed: 2 }
  enum validation_status: { pending: 0, approved: 1, rejected: 2 }
  enum status: { draft: 0, published: 1, reserved: 2, in_negotiation: 3, sold: 4, withdrawn: 5 }
  
  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :industry_sector, presence: true
  validates :seller_profile_id, presence: true
  
  # Scopes
  scope :approved, -> { where(validation_status: :approved) }
  scope :published_listings, -> { where(status: :published) }
  scope :available, -> { approved.published_listings.where.not(status: [:reserved, :sold]) }
  scope :by_sector, ->(sector) { where(industry_sector: sector) }
  
  # Instance methods
  def increment_views!
    increment!(:views_count)
  end
  
  def calculate_completeness
    # 60% for listing fields, 40% for documents
    listing_score = calculate_listing_fields_score
    doc_score = calculate_documents_score
    ((listing_score * 0.6) + (doc_score * 0.4)).round
  end
  
  private
  
  def calculate_listing_fields_score
    fields = [
      title, description_public, description_confidential, industry_sector,
      annual_revenue, employee_count, asking_price, transfer_horizon,
      location_department, location_city, net_profit
    ]
    (fields.compact.count.to_f / fields.count * 100).round
  end
  
  def calculate_documents_score
    total_categories = 11
    uploaded = listing_documents.where(not_applicable: false).select(:document_category).distinct.count
    na_count = listing_documents.where(not_applicable: true).select(:document_category).distinct.count
    ((uploaded + na_count).to_f / total_categories * 100).round
  end
end
```

### deal.rb

```ruby
class Deal < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  
  has_many :deal_history_events, dependent: :destroy
  
  # Enums
  enum status: {
    favorited: 0, to_contact: 1, info_exchange: 2, analysis: 3,
    project_alignment: 4, negotiation: 5, loi: 6, audits: 7,
    financing: 8, signed: 9, released: 10, abandoned: 11
  }
  
  # Validations
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :buyer_profile_id, uniqueness: { scope: :listing_id, conditions: -> { where(released_at: nil) } }
  
  # Scopes
  scope :active, -> { where(released_at: nil) }
  scope :reserved_deals, -> { where(reserved: true) }
  scope :by_status, ->(status) { where(status: status) }
  
  # Callbacks
  after_update :track_status_change, if: :saved_change_to_status?
  
  # Instance methods
  def reserve!
    update!(reserved: true, reserved_at: Time.current, reserved_until: calculate_reserved_until)
  end
  
  def release!(reason = nil)
    credits_earned = calculate_release_credits
    update!(
      released_at: Time.current,
      release_reason: reason,
      total_credits_earned: credits_earned
    )
    buyer_profile.add_credits(credits_earned)
  end
  
  def timer_expired?
    reserved_until.present? && reserved_until < Time.current
  end
  
  private
  
  def calculate_reserved_until
    case status
    when 'to_contact'
      7.days.from_now
    when 'info_exchange', 'analysis', 'project_alignment'
      33.days.from_now
    when 'negotiation'
      20.days.from_now
    else
      nil
    end
  end
  
  def calculate_release_credits
    base_credit = 1
    doc_credits = enrichments.where(validated: true).count
    base_credit + doc_credits
  end
  
  def track_status_change
    deal_history_events.create!(
      event_type: :status_change,
      from_status: status_before_last_save,
      to_status: status,
      user_id: buyer_profile.user_id
    )
  end
end
```

### favorite.rb

```ruby
class Favorite < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :buyer_profile_id, uniqueness: { scope: :listing_id }
end
```

### deal_history_event.rb

```ruby
class DealHistoryEvent < ApplicationRecord
  belongs_to :deal
  belongs_to :user, optional: true
  
  enum event_type: {
    status_change: 0, document_added: 1, message_sent: 2,
    reservation: 3, release: 4, timer_extended: 5, loi_validated: 6
  }
  
  validates :deal_id, presence: true
  validates :event_type, presence: true
end
```

### listing_document.rb

```ruby
class ListingDocument < ApplicationRecord
  belongs_to :listing
  belongs_to :uploaded_by, class_name: 'User'
  
  enum document_category: {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  validates :listing_id, presence: true
  validates :uploaded_by_id, presence: true
  validates :document_category, presence: true
  validates :title, presence: true
  validates :file_name, presence: true
end
```

### enrichment.rb

```ruby
class Enrichment < ApplicationRecord
  belongs_to :buyer_profile
  belongs_to :listing
  belongs_to :validated_by, class_name: 'User', optional: true
  
  enum document_category: {
    balance_n1: 0, balance_n2: 1, balance_n3: 2, org_chart: 3,
    tax_return: 4, income_statement: 5, vehicle_list: 6, lease: 7,
    property_title: 8, scorecard: 9, other: 10
  }
  
  validates :buyer_profile_id, presence: true
  validates :listing_id, presence: true
  validates :document_category, presence: true
  
  scope :validated_enrichments, -> { where(validated: true) }
  scope :pending, -> { where(validated: false) }
end
```

### conversation.rb

```ruby
class Conversation < ApplicationRecord
  belongs_to :listing, optional: true
  
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  
  validates :conversation_participants, length: { minimum: 2 }
  
  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end
  
  def latest_message
    messages.order(created_at: :desc).first
  end
end
```

### conversation_participant.rb

```ruby
class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user
  
  validates :conversation_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :conversation_id }
end
```

### message.rb

```ruby
class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
  
  validates :conversation_id, presence: true
  validates :sender_id, presence: true
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }
  
  after_create :send_notification
  after_create :broadcast_message
  
  scope :unread, -> { where(read: false) }
  
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
  
  private
  
  def send_notification
    # Send email notification to recipient
  end
  
  def broadcast_message
    # Broadcast via Turbo Streams for real-time updates
  end
end
```

### nda_signature.rb

```ruby
class NdaSignature < ApplicationRecord
  belongs_to :user
  belongs_to :listing, optional: true
  
  enum signature_type: { platform_wide: 0, listing_specific: 1 }
  
  validates :user_id, presence: true
  validates :signature_type, presence: true
  validates :signed_at, presence: true
  validates :ip_address, presence: true
end
```

### subscription.rb

```ruby
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :profile, polymorphic: true
  
  enum plan_type: {
    seller_premium: 0, buyer_starter: 1, buyer_standard: 2,
    buyer_premium: 3, buyer_club: 4, partner_directory: 5,
    credit_pack_small: 6, credit_pack_medium: 7, credit_pack_large: 8
  }
  enum status: { pending: 0, active: 1, cancelled: 2, expired: 3, failed: 4 }
  
  validates :user_id, presence: true
  validates :plan_type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
end
```

### notification.rb

```ruby
class Notification < ApplicationRecord
  belongs_to :user
  
  enum notification_type: {
    new_deal: 0, listing_validated: 1, listing_rejected: 2,
    favorite_available: 3, reservation_expiring: 4, subscription_expiring: 5,
    enrichment_validated: 6, new_message: 7, deal_status_changed: 8,
    document_validation_request: 9, listing_pushed: 10, buyer_interested: 11,
    timer_expired: 12, loi_validation_request: 13
  }
  
  validates :user_id, presence: true
  validates :notification_type, presence: true
  validates :title, presence: true
  validates :message, presence: true
  
  scope :unread, -> { where(read: false) }
  
  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end
end
```

### listing_view.rb

```ruby
class ListingView < ApplicationRecord
  belongs_to :listing
  belongs_to :user, optional: true
  
  validates :listing_id, presence: true
  validates :viewed_at, presence: true
end
```

### partner_contact.rb

```ruby
class PartnerContact < ApplicationRecord
  belongs_to :partner_profile
  belongs_to :user
  
  enum contact_type: { view: 0, contact: 1 }
  
  validates :partner_profile_id, presence: true
  validates :user_id, presence: true
  validates :contact_type, presence: true
end
```

### platform_setting.rb

```ruby
class PlatformSetting < ApplicationRecord
  belongs_to :updated_by, class_name: 'User', optional: true
  
  enum setting_type: { string: 0, integer: 1, boolean: 2, json: 3, decimal: 4 }
  
  validates :setting_key, presence: true, uniqueness: true
  validates :setting_value, presence: true
  validates :setting_type, presence: true
  
  def self.get(key)
    find_by(setting_key: key)&.setting_value
  end
  
  def self.set(key, value, updated_by_user = nil)
    setting = find_or_initialize_by(setting_key: key)
    setting.setting_value = value.to_s
    setting.updated_by = updated_by_user
    setting.save
  end
end
```

### questionnaire.rb

```ruby
class Questionnaire < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  
  has_many :questionnaire_responses, dependent: :destroy
  
  enum questionnaire_type: { satisfaction: 0, development: 1 }
  enum target_role: { all: 0, seller: 1, buyer: 2, partner: 3 }
  
  serialize :questions, type: Array, coder: JSON
  
  validates :title, presence: true
  validates :questionnaire_type, presence: true
  validates :questions, presence: true
  validates :created_by_id, presence: true
  
  scope :active_questionnaires, -> { where(active: true) }
end
```

### questionnaire_response.rb

```ruby
class QuestionnaireResponse < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :user
  
  serialize :answers, type: Hash, coder: JSON
  
  validates :questionnaire_id, presence: true
  validates :user_id, presence: true
  validates :answers, presence: true
  validates :completed_at, presence: true
end
```

### lead_import.rb

```ruby
class LeadImport < ApplicationRecord
  belongs_to :imported_by, class_name: 'User'
  
  enum import_status: { pending: 0, processing: 1, completed: 2, failed: 3 }
  
  validates :imported_by_id, presence: true
  validates :file_name, presence: true
  validates :total_rows, presence: true, numericality: { greater_than: 0 }
  validates :import_status, presence: true
end
```

### activity.rb

```ruby
class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true
  
  enum action_type: {
    user_created: 0, user_updated: 1, listing_created: 2, listing_validated: 3,
    listing_rejected: 4, deal_created: 5, deal_updated: 6, deal_released: 7,
    nda_signed: 8, payment_processed: 9, import_completed: 10, message_sent: 11,
    document_uploaded: 12, enrichment_submitted: 13, settings_updated: 14
  }
  
  validates :action_type, presence: true
  
  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :by_user, ->(user) { where(user: user) }
end
```

---

## Next Steps

1. Copy each migration content from above into the respective migration file
2. Copy each model content from above into a new file in `app/models/`
3. Run `rails db:migrate` to apply all migrations
4. Review and test the implementation

## Summary

- **Total Models**: 23 models (including User)
- **Total Migrations**: 23 migrations
- **All models follow Rails conventions**
- **All relationships properly defined**
- **Proper indexing for performance**
- **Enums use integer backing**
- **JSON fields use text with serialization**
- **Decimal fields have proper precision**
