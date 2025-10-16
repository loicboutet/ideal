Rails.application.routes.draw do
  get "home/index"
  devise_for :users

  # Mockups routes - Public Pages
  get "mockups", to: "mockups#index", as: :mockups
  get "mockups/about", to: "mockups#about", as: :mockups_about
  get "mockups/how_it_works", to: "mockups#how_it_works", as: :mockups_how_it_works
  get "mockups/pricing", to: "mockups#pricing", as: :mockups_pricing
  get "mockups/contact", to: "mockups#contact", as: :mockups_contact

  # Mockups routes - User Journey
  get "mockups/user_dashboard"
  get "mockups/user_profile"
  get "mockups/user_settings"

  # Mockups routes - Admin Journey
  get "mockups/admin_dashboard"
  get "mockups/admin_users"
  get "mockups/admin_analytics"

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