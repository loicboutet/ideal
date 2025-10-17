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
  
  # Mockups routes - Admin Users
  get "mockups/admin/users", to: "mockups/admin/users#index", as: :mockups_admin_users
  get "mockups/admin/users/new", to: "mockups/admin/users#new", as: :new_mockups_admin_user
  get "mockups/admin/users/:id", to: "mockups/admin/users#show", as: :mockups_admin_user
  get "mockups/admin/users/:id/edit", to: "mockups/admin/users#edit", as: :edit_mockups_admin_user
  get "mockups/admin/users/:id/suspend", to: "mockups/admin/users#suspend_confirm", as: :suspend_mockups_admin_user

  # Mockups routes - Admin Listings
  get "mockups/admin/listings", to: "mockups/admin/listings#index", as: :mockups_admin_listings
  get "mockups/admin/listings/pending", to: "mockups/admin/listings#pending", as: :mockups_admin_listings_pending
  get "mockups/admin/listings/:id", to: "mockups/admin/listings#show", as: :mockups_admin_listing
  get "mockups/admin/listings/:id/validate", to: "mockups/admin/listings#validate_form", as: :validate_mockups_admin_listing
  get "mockups/admin/listings/:id/reject", to: "mockups/admin/listings#reject_form", as: :reject_mockups_admin_listing

  # Mockups routes - Admin Partners
  get "mockups/admin/partners", to: "mockups/admin/partners#index", as: :mockups_admin_partners
  get "mockups/admin/partners/pending", to: "mockups/admin/partners#pending", as: :mockups_admin_partners_pending
  get "mockups/admin/partners/:id", to: "mockups/admin/partners#show", as: :mockups_admin_partner
  get "mockups/admin/partners/:id/approve", to: "mockups/admin/partners#approve_form", as: :approve_mockups_admin_partner
  get "mockups/admin/partners/:id/reject", to: "mockups/admin/partners#reject_form", as: :reject_mockups_admin_partner

  # Mockups routes - Admin Deals
  get "mockups/admin/deals", to: "mockups/admin/deals#index", as: :mockups_admin_deals
  get "mockups/admin/deals/:id", to: "mockups/admin/deals#show", as: :mockups_admin_deal
  get "mockups/admin/deals/:id/assign", to: "mockups/admin/deals#assign_form", as: :assign_mockups_admin_deal

  # Mockups routes - User Journey
  get "mockups/user_dashboard"
  get "mockups/user_profile"
  get "mockups/user_settings"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "mockups#index"
end