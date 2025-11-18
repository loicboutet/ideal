# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_18_202728) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "user_id"
    t.string "trackable_type"
    t.integer "trackable_id"
    t.integer "action_type", null: false
    t.json "metadata"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_activities_on_action_type"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "buyer_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "subscription_plan", default: 0, null: false
    t.integer "subscription_status", default: 0, null: false
    t.datetime "subscription_expires_at"
    t.integer "credits", default: 0, null: false
    t.string "stripe_customer_id"
    t.boolean "verified_buyer", default: false, null: false
    t.integer "profile_status", default: 0, null: false
    t.integer "completeness_score", default: 0, null: false
    t.integer "buyer_type"
    t.text "formation"
    t.text "experience"
    t.text "skills"
    t.text "investment_thesis"
    t.text "target_sectors"
    t.text "target_locations"
    t.decimal "target_revenue_min", precision: 15, scale: 2
    t.decimal "target_revenue_max", precision: 15, scale: 2
    t.integer "target_employees_min"
    t.integer "target_employees_max"
    t.integer "target_financial_health"
    t.string "target_horizon"
    t.text "target_transfer_types"
    t.text "target_customer_types"
    t.decimal "investment_capacity", precision: 15, scale: 2
    t.text "funding_sources"
    t.string "linkedin_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_status"], name: "index_buyer_profiles_on_profile_status"
    t.index ["stripe_customer_id"], name: "index_buyer_profiles_on_stripe_customer_id"
    t.index ["subscription_plan"], name: "index_buyer_profiles_on_subscription_plan"
    t.index ["subscription_status"], name: "index_buyer_profiles_on_subscription_status"
    t.index ["user_id"], name: "index_buyer_profiles_on_user_id", unique: true
    t.index ["verified_buyer"], name: "index_buyer_profiles_on_verified_buyer"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "user_id", null: false
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "user_id"], name: "index_conv_participants_on_conv_and_user", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "listing_id"
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
  end

  create_table "deal_history_events", force: :cascade do |t|
    t.integer "deal_id", null: false
    t.integer "user_id"
    t.integer "event_type", null: false
    t.integer "from_status"
    t.integer "to_status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_deal_history_events_on_created_at"
    t.index ["deal_id"], name: "index_deal_history_events_on_deal_id"
    t.index ["event_type"], name: "index_deal_history_events_on_event_type"
    t.index ["user_id"], name: "index_deal_history_events_on_user_id"
  end

  create_table "deals", force: :cascade do |t|
    t.integer "buyer_profile_id", null: false
    t.integer "listing_id", null: false
    t.integer "status", default: 0, null: false
    t.boolean "reserved", default: false, null: false
    t.datetime "reserved_at"
    t.datetime "reserved_until"
    t.datetime "stage_entered_at"
    t.integer "time_in_stage", default: 0, null: false
    t.integer "total_credits_earned", default: 0, null: false
    t.boolean "loi_seller_validated", default: false, null: false
    t.text "notes"
    t.datetime "released_at"
    t.text "release_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_profile_id", "listing_id"], name: "index_deals_on_buyer_profile_id_and_listing_id", unique: true, where: "released_at IS NULL"
    t.index ["buyer_profile_id"], name: "index_deals_on_buyer_profile_id"
    t.index ["listing_id"], name: "index_deals_on_listing_id"
    t.index ["reserved"], name: "index_deals_on_reserved"
    t.index ["reserved_until"], name: "index_deals_on_reserved_until"
    t.index ["status"], name: "index_deals_on_status"
  end

  create_table "enrichments", force: :cascade do |t|
    t.integer "buyer_profile_id", null: false
    t.integer "listing_id", null: false
    t.integer "validated_by_id"
    t.integer "document_category", null: false
    t.text "description"
    t.integer "credits_awarded", default: 0, null: false
    t.boolean "validated", default: false, null: false
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_profile_id"], name: "index_enrichments_on_buyer_profile_id"
    t.index ["listing_id", "buyer_profile_id"], name: "index_enrichments_on_listing_id_and_buyer_profile_id"
    t.index ["listing_id"], name: "index_enrichments_on_listing_id"
    t.index ["validated"], name: "index_enrichments_on_validated"
    t.index ["validated_by_id"], name: "index_enrichments_on_validated_by_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "buyer_profile_id", null: false
    t.integer "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_profile_id", "listing_id"], name: "index_favorites_on_buyer_profile_id_and_listing_id", unique: true
    t.index ["buyer_profile_id"], name: "index_favorites_on_buyer_profile_id"
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
  end

  create_table "lead_imports", force: :cascade do |t|
    t.integer "imported_by_id", null: false
    t.string "file_name", null: false
    t.integer "total_rows", null: false
    t.integer "successful_imports", default: 0, null: false
    t.integer "failed_imports", default: 0, null: false
    t.integer "import_status", default: 0, null: false
    t.text "error_log"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_status"], name: "index_lead_imports_on_import_status"
    t.index ["imported_by_id"], name: "index_lead_imports_on_imported_by_id"
  end

  create_table "listing_documents", force: :cascade do |t|
    t.integer "listing_id", null: false
    t.integer "uploaded_by_id", null: false
    t.integer "document_category", null: false
    t.string "title", null: false
    t.text "description"
    t.string "file_name", null: false
    t.string "file_path", null: false
    t.integer "file_size", null: false
    t.string "content_type", null: false
    t.boolean "not_applicable", default: false, null: false
    t.boolean "nda_required", default: true, null: false
    t.boolean "validated_by_seller", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_category"], name: "index_listing_documents_on_document_category"
    t.index ["listing_id", "document_category"], name: "index_listing_documents_on_listing_id_and_document_category"
    t.index ["listing_id"], name: "index_listing_documents_on_listing_id"
    t.index ["uploaded_by_id"], name: "index_listing_documents_on_uploaded_by_id"
  end

  create_table "listing_pushes", force: :cascade do |t|
    t.integer "listing_id", null: false
    t.integer "buyer_profile_id", null: false
    t.integer "seller_profile_id", null: false
    t.datetime "pushed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_profile_id"], name: "index_listing_pushes_on_buyer_profile_id"
    t.index ["listing_id"], name: "index_listing_pushes_on_listing_id"
    t.index ["seller_profile_id"], name: "index_listing_pushes_on_seller_profile_id"
  end

  create_table "listing_views", force: :cascade do |t|
    t.integer "listing_id", null: false
    t.integer "user_id"
    t.string "ip_address"
    t.datetime "viewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "user_id"], name: "index_listing_views_on_listing_id_and_user_id"
    t.index ["listing_id"], name: "index_listing_views_on_listing_id"
    t.index ["user_id"], name: "index_listing_views_on_user_id"
    t.index ["viewed_at"], name: "index_listing_views_on_viewed_at"
  end

  create_table "listings", force: :cascade do |t|
    t.integer "seller_profile_id", null: false
    t.integer "attributed_buyer_id"
    t.integer "deal_type", default: 0, null: false
    t.integer "validation_status", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.text "description_public"
    t.integer "industry_sector", null: false
    t.string "location_department"
    t.string "location_region"
    t.string "location_country", default: "France"
    t.text "description_confidential"
    t.string "location_city"
    t.string "website"
    t.decimal "annual_revenue", precision: 15, scale: 2
    t.integer "employee_count"
    t.decimal "net_profit", precision: 15, scale: 2
    t.decimal "asking_price", precision: 15, scale: 2
    t.decimal "price_min", precision: 15, scale: 2
    t.decimal "price_max", precision: 15, scale: 2
    t.decimal "net_revenue_ratio", precision: 5, scale: 2
    t.string "transfer_horizon"
    t.integer "transfer_type"
    t.integer "company_age"
    t.integer "customer_type"
    t.string "legal_form"
    t.boolean "show_scorecard_stars", default: false, null: false
    t.integer "scorecard_stars"
    t.integer "completeness_score", default: 0, null: false
    t.integer "views_count", default: 0, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.datetime "validated_at"
    t.text "rejection_reason"
    t.text "validation_notes"
    t.index ["attributed_buyer_id"], name: "index_listings_on_attributed_buyer_id"
    t.index ["deal_type"], name: "index_listings_on_deal_type"
    t.index ["industry_sector"], name: "index_listings_on_industry_sector"
    t.index ["location_department"], name: "index_listings_on_location_department"
    t.index ["published_at"], name: "index_listings_on_published_at"
    t.index ["seller_profile_id", "status"], name: "index_listings_on_seller_profile_id_and_status"
    t.index ["seller_profile_id"], name: "index_listings_on_seller_profile_id"
    t.index ["status"], name: "index_listings_on_status"
    t.index ["validation_status"], name: "index_listings_on_validation_status"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "conversation_id", null: false
    t.integer "sender_id", null: false
    t.text "body", null: false
    t.boolean "read", default: false, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["read"], name: "index_messages_on_read"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "nda_signatures", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "listing_id"
    t.integer "signature_type", null: false
    t.datetime "signed_at", null: false
    t.string "ip_address", null: false
    t.string "user_agent"
    t.boolean "accepted_terms", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_nda_signatures_on_listing_id"
    t.index ["signature_type"], name: "index_nda_signatures_on_signature_type"
    t.index ["signed_at"], name: "index_nda_signatures_on_signed_at"
    t.index ["user_id", "listing_id"], name: "index_nda_signatures_on_user_id_and_listing_id"
    t.index ["user_id"], name: "index_nda_signatures_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "notification_type", null: false
    t.string "title", null: false
    t.text "message", null: false
    t.string "link_url"
    t.boolean "read", default: false, null: false
    t.datetime "read_at"
    t.boolean "sent_via_email", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "partner_contacts", force: :cascade do |t|
    t.integer "partner_profile_id", null: false
    t.integer "user_id", null: false
    t.integer "contact_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_type"], name: "index_partner_contacts_on_contact_type"
    t.index ["created_at"], name: "index_partner_contacts_on_created_at"
    t.index ["partner_profile_id"], name: "index_partner_contacts_on_partner_profile_id"
    t.index ["user_id"], name: "index_partner_contacts_on_user_id"
  end

  create_table "partner_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "partner_type", null: false
    t.text "description"
    t.text "services_offered"
    t.string "calendar_link"
    t.string "website"
    t.integer "coverage_area"
    t.text "coverage_details"
    t.text "intervention_stages"
    t.text "industry_specializations"
    t.integer "validation_status", default: 0, null: false
    t.datetime "directory_subscription_expires_at"
    t.integer "views_count", default: 0, null: false
    t.integer "contacts_count", default: 0, null: false
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage_area"], name: "index_partner_profiles_on_coverage_area"
    t.index ["partner_type"], name: "index_partner_profiles_on_partner_type"
    t.index ["stripe_customer_id"], name: "index_partner_profiles_on_stripe_customer_id"
    t.index ["user_id"], name: "index_partner_profiles_on_user_id", unique: true
    t.index ["validation_status"], name: "index_partner_profiles_on_validation_status"
  end

  create_table "platform_settings", force: :cascade do |t|
    t.string "setting_key", null: false
    t.text "setting_value", null: false
    t.integer "setting_type", null: false
    t.text "description"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["setting_key"], name: "index_platform_settings_on_setting_key", unique: true
    t.index ["updated_by_id"], name: "index_platform_settings_on_updated_by_id"
  end

  create_table "questionnaire_responses", force: :cascade do |t|
    t.integer "questionnaire_id", null: false
    t.integer "user_id", null: false
    t.text "answers", null: false
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_id", "user_id"], name: "index_questionnaire_responses_on_questionnaire_id_and_user_id"
    t.index ["questionnaire_id"], name: "index_questionnaire_responses_on_questionnaire_id"
    t.index ["user_id"], name: "index_questionnaire_responses_on_user_id"
  end

  create_table "questionnaires", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "questionnaire_type", null: false
    t.text "questions", null: false
    t.integer "target_role"
    t.boolean "active", default: true, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_questionnaires_on_active"
    t.index ["created_by_id"], name: "index_questionnaires_on_created_by_id"
    t.index ["questionnaire_type"], name: "index_questionnaires_on_questionnaire_type"
  end

  create_table "seller_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "is_broker", default: false, null: false
    t.boolean "premium_access", default: false, null: false
    t.integer "credits", default: 0, null: false
    t.integer "free_contacts_used", default: 0, null: false
    t.integer "free_contacts_limit", default: 4, null: false
    t.boolean "receive_signed_nda", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_broker"], name: "index_seller_profiles_on_is_broker"
    t.index ["premium_access"], name: "index_seller_profiles_on_premium_access"
    t.index ["user_id"], name: "index_seller_profiles_on_user_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "profile_type", null: false
    t.integer "profile_id", null: false
    t.string "stripe_subscription_id"
    t.integer "plan_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "EUR", null: false
    t.integer "status", null: false
    t.datetime "period_start", null: false
    t.datetime "period_end", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_type", "profile_id"], name: "index_subscriptions_on_profile"
    t.index ["profile_type", "profile_id"], name: "index_subscriptions_on_profile_type_and_profile_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_subscriptions_on_stripe_subscription_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 2, null: false
    t.integer "status", default: 1, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "company_name"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "buyer_profiles", "users"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "conversations", "listings"
  add_foreign_key "deal_history_events", "deals"
  add_foreign_key "deal_history_events", "users"
  add_foreign_key "deals", "buyer_profiles"
  add_foreign_key "deals", "listings"
  add_foreign_key "enrichments", "buyer_profiles"
  add_foreign_key "enrichments", "listings"
  add_foreign_key "enrichments", "users", column: "validated_by_id"
  add_foreign_key "favorites", "buyer_profiles"
  add_foreign_key "favorites", "listings"
  add_foreign_key "lead_imports", "users", column: "imported_by_id"
  add_foreign_key "listing_documents", "listings"
  add_foreign_key "listing_documents", "users", column: "uploaded_by_id"
  add_foreign_key "listing_pushes", "buyer_profiles"
  add_foreign_key "listing_pushes", "listings"
  add_foreign_key "listing_pushes", "seller_profiles"
  add_foreign_key "listing_views", "listings"
  add_foreign_key "listing_views", "users"
  add_foreign_key "listings", "buyer_profiles", column: "attributed_buyer_id"
  add_foreign_key "listings", "seller_profiles"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "nda_signatures", "listings"
  add_foreign_key "nda_signatures", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "partner_contacts", "partner_profiles"
  add_foreign_key "partner_contacts", "users"
  add_foreign_key "partner_profiles", "users"
  add_foreign_key "platform_settings", "users", column: "updated_by_id"
  add_foreign_key "questionnaire_responses", "questionnaires"
  add_foreign_key "questionnaire_responses", "users"
  add_foreign_key "questionnaires", "users", column: "created_by_id"
  add_foreign_key "seller_profiles", "users"
  add_foreign_key "subscriptions", "users"
end
