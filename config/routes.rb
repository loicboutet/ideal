Rails.application.routes.draw do
  get "home/index"
  devise_for :users

  # Mockups routes - Public Pages
  get "mockups", to: "mockups#index", as: :mockups
  get "mockups/about", to: "mockups#about", as: :mockups_about
  get "mockups/how_it_works", to: "mockups#how_it_works", as: :mockups_how_it_works
  get "mockups/pricing", to: "mockups#pricing", as: :mockups_pricing
  get "mockups/contact", to: "mockups#contact", as: :mockups_contact

  # Mockups routes - Authentication
  get "mockups/login", to: "mockups/auth#login", as: :mockups_login
  get "mockups/register", to: "mockups/auth#register", as: :mockups_register
  get "mockups/register/seller", to: "mockups/auth#register_seller", as: :mockups_register_seller
  get "mockups/register/buyer", to: "mockups/auth#register_buyer", as: :mockups_register_buyer
  get "mockups/register/partner", to: "mockups/auth#register_partner", as: :mockups_register_partner
  get "mockups/forgot_password", to: "mockups/auth#forgot_password", as: :mockups_forgot_password
  get "mockups/reset_password", to: "mockups/auth#reset_password", as: :mockups_reset_password

  # Mockups routes - Browse Listings (Freemium Access)
  get "mockups/listings", to: "mockups/listings#index", as: :mockups_listings
  get "mockups/listings/search", to: "mockups/listings#search", as: :mockups_listings_search
  get "mockups/listings/:id", to: "mockups/listings#show", as: :mockups_listing

  # Mockups routes - Admin
  get "mockups/admin", to: "mockups/admin#dashboard", as: :mockups_admin
  get "mockups/admin/analytics", to: "mockups/admin#analytics", as: :mockups_admin_analytics
  get "mockups/admin/operations", to: "mockups/admin#operations", as: :mockups_admin_operations
  get "mockups/admin/settings", to: "mockups/admin#settings", as: :mockups_admin_settings
  get "mockups/admin/messages", to: "mockups/admin#messages", as: :mockups_admin_messages
  
  # Mockups routes - Admin Users
  get "mockups/admin/users", to: "mockups/admin/users#index", as: :mockups_admin_users
  get "mockups/admin/users/new", to: "mockups/admin/users#new", as: :new_mockups_admin_user
  get "mockups/admin/users/new/seller", to: "mockups/admin/users#new_seller", as: :new_seller_mockups_admin_user
  get "mockups/admin/users/new/buyer", to: "mockups/admin/users#new_buyer", as: :new_buyer_mockups_admin_user
  get "mockups/admin/users/new/partner", to: "mockups/admin/users#new_partner", as: :new_partner_mockups_admin_user
  get "mockups/admin/users/:id", to: "mockups/admin/users#show", as: :mockups_admin_user
  get "mockups/admin/users/:id/edit", to: "mockups/admin/users#edit", as: :edit_mockups_admin_user
  get "mockups/admin/users/:id/suspend", to: "mockups/admin/users#suspend_confirm", as: :suspend_mockups_admin_user

  # Mockups routes - Admin Listings
  get "mockups/admin/listings", to: "mockups/admin/listings#index", as: :mockups_admin_listings
  get "mockups/admin/listings/pending", to: "mockups/admin/listings#pending", as: :mockups_admin_listings_pending
  get "mockups/admin/listings/new", to: "mockups/admin/listings#new", as: :new_mockups_admin_listing
  get "mockups/admin/listings/:id", to: "mockups/admin/listings#show", as: :mockups_admin_listing
  get "mockups/admin/listings/:id/validate", to: "mockups/admin/listings#validate_form", as: :validate_mockups_admin_listing
  get "mockups/admin/listings/:id/reject", to: "mockups/admin/listings#reject_form", as: :reject_mockups_admin_listing

  # Mockups routes - Admin Partners
  get "mockups/admin/partners", to: "mockups/admin/partners#index", as: :mockups_admin_partners
  get "mockups/admin/partners/pending", to: "mockups/admin/partners#pending", as: :mockups_admin_partners_pending
  get "mockups/admin/partners/new", to: "mockups/admin/partners#new", as: :new_mockups_admin_partner
  get "mockups/admin/partners/:id", to: "mockups/admin/partners#show", as: :mockups_admin_partner
  get "mockups/admin/partners/:id/approve", to: "mockups/admin/partners#approve_form", as: :approve_mockups_admin_partner
  get "mockups/admin/partners/:id/reject", to: "mockups/admin/partners#reject_form", as: :reject_mockups_admin_partner

  # Mockups routes - Admin Deals
  get "mockups/admin/deals", to: "mockups/admin/deals#index", as: :mockups_admin_deals
  get "mockups/admin/deals/:id", to: "mockups/admin/deals#show", as: :mockups_admin_deal
  get "mockups/admin/deals/:id/assign", to: "mockups/admin/deals#assign_form", as: :assign_mockups_admin_deal

  # Mockups routes - Admin Imports
  get "mockups/admin/imports", to: "mockups/admin/imports#index", as: :mockups_admin_imports
  get "mockups/admin/imports/new", to: "mockups/admin/imports#new", as: :new_mockups_admin_import
  get "mockups/admin/imports/:id", to: "mockups/admin/imports#show", as: :mockups_admin_import

  # Mockups routes - Admin Enrichments
  get "mockups/admin/enrichments", to: "mockups/admin/enrichments#index", as: :mockups_admin_enrichments
  get "mockups/admin/enrichments/:id", to: "mockups/admin/enrichments#show", as: :mockups_admin_enrichment
  get "mockups/admin/enrichments/:id/approve", to: "mockups/admin/enrichments#approve_form", as: :approve_mockups_admin_enrichment

  # Mockups routes - Seller Dashboard
  get "mockups/seller", to: "mockups/seller#dashboard", as: :mockups_seller

  # Mockups routes - Seller Listings
  get "mockups/seller/listings", to: "mockups/seller/listings#index", as: :mockups_seller_listings
  get "mockups/seller/listings/new", to: "mockups/seller/listings#new", as: :new_mockups_seller_listing
  get "mockups/seller/listings/:id", to: "mockups/seller/listings#show", as: :mockups_seller_listing
  get "mockups/seller/listings/:id/edit", to: "mockups/seller/listings#edit", as: :edit_mockups_seller_listing
  get "mockups/seller/listings/:id/documents", to: "mockups/seller/listings#documents", as: :mockups_seller_listing_documents
  get "mockups/seller/listings/:id/documents/new", to: "mockups/seller/listings#new_document", as: :new_mockups_seller_listing_document
  get "mockups/seller/listings/new/confidential", to: "mockups/seller/listings#new_confidential", as: :new_confidential_mockups_seller_listing

  # Mockups routes - Seller Interests
  get "mockups/seller/interests", to: "mockups/seller/interests#index", as: :mockups_seller_interests
  get "mockups/seller/interests/:id", to: "mockups/seller/interests#show", as: :mockups_seller_interest

  # Mockups routes - Seller Buyers (NEW)
  get "mockups/seller/buyers", to: "mockups/seller/buyers#index", as: :mockups_seller_buyers
  get "mockups/seller/buyers/search", to: "mockups/seller/buyers#search", as: :search_mockups_seller_buyers
  get "mockups/seller/buyers/:id", to: "mockups/seller/buyers#show", as: :mockups_seller_buyer
  
  # Mockups routes - Seller Push Listing (NEW)
  get "mockups/seller/push_listing", to: "mockups/seller#push_listing", as: :mockups_seller_push_listing
  
  # Mockups routes - Seller Assistance (NEW)
  get "mockups/seller/assistance/support", to: "mockups/seller/assistance#support", as: :mockups_seller_assistance_support
  get "mockups/seller/assistance/partners", to: "mockups/seller/assistance#partners", as: :mockups_seller_assistance_partners
  get "mockups/seller/assistance/tools", to: "mockups/seller/assistance#tools", as: :mockups_seller_assistance_tools

  # Mockups routes - Seller Profile & Settings
  get "mockups/seller/profile", to: "mockups/seller/profile#show", as: :mockups_seller_profile
  get "mockups/seller/profile/edit", to: "mockups/seller/profile#edit", as: :edit_mockups_seller_profile
  get "mockups/seller/settings", to: "mockups/seller/settings#show", as: :mockups_seller_settings
  get "mockups/seller/subscription", to: "mockups/seller/subscription#show", as: :mockups_seller_subscription

  # Mockups routes - Seller NDA
  get "mockups/seller/nda", to: "mockups/seller/nda#show", as: :mockups_seller_nda

  # Mockups routes - Buyer Dashboard
  get "mockups/buyer", to: "mockups/buyer#dashboard", as: :mockups_buyer

  # Mockups routes - Buyer Browse & Search
  get "mockups/buyer/listings", to: "mockups/buyer/listings#index", as: :mockups_buyer_listings
  get "mockups/buyer/listings/search", to: "mockups/buyer/listings#search", as: :mockups_buyer_listings_search
  get "mockups/buyer/listings/:id", to: "mockups/buyer/listings#show", as: :mockups_buyer_listing

  # Mockups routes - Buyer CRM / Pipeline Management
  get "mockups/buyer/pipeline", to: "mockups/buyer/pipeline#index", as: :mockups_buyer_pipeline
  get "mockups/buyer/deals", to: "mockups/buyer/deals#index", as: :mockups_buyer_deals
  get "mockups/buyer/deals/new", to: "mockups/buyer/deals#new", as: :new_mockups_buyer_deal
  get "mockups/buyer/deals/:id", to: "mockups/buyer/deals#show", as: :mockups_buyer_deal
  get "mockups/buyer/deals/:id/edit", to: "mockups/buyer/deals#edit", as: :edit_mockups_buyer_deal

  # Mockups routes - Buyer Favorites
  get "mockups/buyer/favorites", to: "mockups/buyer/favorites#index", as: :mockups_buyer_favorites

  # Mockups routes - Buyer Reservations
  get "mockups/buyer/reservations", to: "mockups/buyer/reservations#index", as: :mockups_buyer_reservations
  get "mockups/buyer/reservations/:id", to: "mockups/buyer/reservations#show", as: :mockups_buyer_reservation
  get "mockups/buyer/reservations/:id/release", to: "mockups/buyer/reservations#release_confirm", as: :release_mockups_buyer_reservation

  # Mockups routes - Buyer Credits & Subscription
  get "mockups/buyer/credits", to: "mockups/buyer/credits#index", as: :mockups_buyer_credits
  get "mockups/buyer/subscription", to: "mockups/buyer/subscription#show", as: :mockups_buyer_subscription
  get "mockups/buyer/subscription/upgrade", to: "mockups/buyer/subscription#upgrade", as: :upgrade_mockups_buyer_subscription
  get "mockups/buyer/subscription/cancel", to: "mockups/buyer/subscription#cancel_confirm", as: :cancel_mockups_buyer_subscription

  # Mockups routes - Buyer Profile & Settings
  get "mockups/buyer/profile", to: "mockups/buyer/profile#show", as: :mockups_buyer_profile
  get "mockups/buyer/profile/edit", to: "mockups/buyer/profile#edit", as: :edit_mockups_buyer_profile
  get "mockups/buyer/profile/create", to: "mockups/buyer/profile#create", as: :create_mockups_buyer_profile
  get "mockups/buyer/settings", to: "mockups/buyer/settings#show", as: :mockups_buyer_settings

  # Mockups routes - Buyer Services (NEW)
  get "mockups/buyer/services/sourcing", to: "mockups/buyer/services#sourcing", as: :mockups_buyer_services_sourcing
  get "mockups/buyer/services/partners", to: "mockups/buyer/services#partners", as: :mockups_buyer_services_partners
  get "mockups/buyer/services/tools", to: "mockups/buyer/services#tools", as: :mockups_buyer_services_tools

  # Mockups routes - Buyer NDA
  get "mockups/buyer/nda", to: "mockups/buyer/nda#show", as: :mockups_buyer_nda
  get "mockups/buyer/nda/listing/:id", to: "mockups/buyer/nda#listing_nda", as: :mockups_buyer_listing_nda

  # Mockups routes - Partner Dashboard
  get "mockups/partner", to: "mockups/partner#dashboard", as: :mockups_partner

  # Mockups routes - Partner Profile & Directory
  get "mockups/partner/profile", to: "mockups/partner/profile#show", as: :mockups_partner_profile
  get "mockups/partner/profile/edit", to: "mockups/partner/profile#edit", as: :edit_mockups_partner_profile
  get "mockups/partner/profile/preview", to: "mockups/partner/profile#preview", as: :preview_mockups_partner_profile

  # Mockups routes - Partner Subscription
  get "mockups/partner/subscription", to: "mockups/partner/subscription#show", as: :mockups_partner_subscription
  get "mockups/partner/subscription/renew", to: "mockups/partner/subscription#renew", as: :renew_mockups_partner_subscription

  # Mockups routes - Partner Settings
  get "mockups/partner/settings", to: "mockups/partner/settings#show", as: :mockups_partner_settings

  # Mockups routes - Partner Directory (Public Browse)
  get "mockups/directory", to: "mockups/directory#index", as: :mockups_directory
  get "mockups/directory/search", to: "mockups/directory#search", as: :search_mockups_directory
  get "mockups/directory/:id", to: "mockups/directory#show", as: :mockups_directory_partner

  # Mockups routes - Shared/Common (Notifications)
  get "mockups/notifications", to: "mockups/notifications#index", as: :mockups_notifications
  get "mockups/notifications/:id", to: "mockups/notifications#show", as: :mockups_notification

  # Mockups routes - Messages (NEW)
  get "mockups/messages", to: "mockups/messages#index", as: :mockups_messages
  get "mockups/messages/new", to: "mockups/messages#new", as: :new_mockups_message
  get "mockups/messages/:id", to: "mockups/messages#show", as: :mockups_message

  # Mockups routes - Shared/Common (Legal Pages)
  get "mockups/terms", to: "mockups/legal#terms", as: :mockups_terms
  get "mockups/privacy", to: "mockups/legal#privacy", as: :mockups_privacy
  get "mockups/nda_template", to: "mockups/legal#nda_template", as: :mockups_nda_template

  # Mockups routes - Payment/Checkout
  get "mockups/checkout/select_plan", to: "mockups/checkout#select_plan", as: :mockups_checkout_select_plan
  get "mockups/checkout/payment", to: "mockups/checkout#payment_form", as: :mockups_checkout_payment
  get "mockups/checkout/success", to: "mockups/checkout#success", as: :mockups_checkout_success
  get "mockups/checkout/cancel", to: "mockups/checkout#cancel", as: :mockups_checkout_cancel

  # Mockups routes - Error Pages
  get "mockups/404", to: "mockups/errors#not_found", as: :mockups_error_404
  get "mockups/403", to: "mockups/errors#forbidden", as: :mockups_error_403
  get "mockups/500", to: "mockups/errors#server_error", as: :mockups_error_500

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Mockups overview - root route
  get "mockups/overview", to: "mockups#overview", as: :mockups_overview

  # Root
  root "mockups#overview"

  # Catch-all route for 404 errors - MUST BE LAST
  match '*unmatched', to: 'application#render_404', via: :all, constraints: lambda { |req|
    !req.path.starts_with?('/rails/') && 
    !req.path.starts_with?('/assets/') &&
    !req.path.ends_with?('.ico')
  }
end
