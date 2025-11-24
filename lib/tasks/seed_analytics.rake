# frozen_string_literal: true

namespace :db do
  desc "Seed analytics data for listing #24 to show full analytics page"
  task seed_analytics: :environment do
    puts "\n🌱 Starting analytics data seeding for listing #24..."
    
    begin
      # ====================
      # STEP 1: Ensure listing #24 exists
      # ====================
      puts "\n📋 Step 1: Setting up listing #24..."
      
      # Find or create a seller
      seller_user = User.sellers.first
      unless seller_user
        puts "❌ No seller found. Please run 'rake db:seed_users' first."
        exit
      end
      
      seller_profile = seller_user.seller_profile
      
      # Find or create listing #24
      listing = Listing.find_by(id: 24)
      
      if listing
        puts "  ✓ Found existing listing #24: #{listing.title}"
      else
        # Create new listing with ID 24
        listing = seller_profile.listings.new(
          id: 24,
          title: "Restaurant Gastronomique - Centre-ville Paris",
          industry_sector: :hospitality,
          location_department: "75",
          location_region: "Île-de-France",
          location_city: "Paris",
          
          description_public: "Restaurant gastronomique réputé situé au cœur de Paris, dans un quartier " \
                              "très fréquenté. Établissement haut de gamme avec une clientèle fidèle et " \
                              "une excellente réputation. Cuisine française raffinée, carte des vins " \
                              "exceptionnelle. Capacité de 60 couverts. Équipement moderne et aux normes.",
          
          description_confidential: "Chiffre d'affaires en croissance constante depuis 5 ans. Équipe stable " \
                                   "de 12 collaborateurs qualifiés. Bail commercial sécurisé pour 9 ans. " \
                                   "Raison de cession: projet de retraite. Locaux rénovés récemment. " \
                                   "Deux salles privées pour événements. Terrasse extérieure 20 places.",
          
          annual_revenue: 1_200_000,
          net_profit: 180_000,
          employee_count: 12,
          company_age: 15,
          
          asking_price: 850_000,
          price_min: 800_000,
          price_max: 900_000,
          
          transfer_horizon: "6-12 mois",
          transfer_type: :total_shares,
          customer_type: :b2c,
          legal_form: "SARL",
          website: "https://restaurant-gastronomique-paris.fr",
          
          deal_type: :ideal_mandate,
          status: :published,
          validation_status: :approved,
          validated_at: 30.days.ago,
          submitted_at: 35.days.ago,
          
          views_count: 0, # Will be updated later
          completeness_score: 92,
          
          created_at: 60.days.ago,
          updated_at: 25.days.ago
        )
        
        listing.save!(validate: false) # Skip validations to allow custom ID
        puts "  ✓ Created listing #24: #{listing.title}"
      end
      
      # Update listing to ensure it's approved and published
      listing.update_columns(
        validation_status: :approved,
        status: :published,
        validated_at: 30.days.ago
      )
      
      # ====================
      # STEP 2: Create buyer users with profiles
      # ====================
      puts "\n💼 Step 2: Creating buyer users with complete profiles..."
      
      buyer_data = [
        {
          first_name: "Marc", last_name: "Dubois", buyer_type: :individual,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Commerce"], locations: ["Paris", "Île-de-France"],
          revenue_min: 500_000, revenue_max: 2_000_000, investment: 1_000_000,
          formation: "MBA HEC Paris", experience: "15 ans dans la restauration",
          skills: "Gestion d'équipe, Finance, Marketing"
        },
        {
          first_name: "Sophie", last_name: "Laurent", buyer_type: :holding,
          subscription_plan: :club, verified: true,
          sectors: ["Hospitality", "Services"], locations: ["Paris", "Lyon", "Marseille"],
          revenue_min: 800_000, revenue_max: 5_000_000, investment: 3_000_000,
          formation: "ESSEC Business School", experience: "20 ans acquisition d'entreprises",
          skills: "Private Equity, Due Diligence, Négociation"
        },
        {
          first_name: "Pierre", last_name: "Martin", buyer_type: :fund,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Commerce", "Services"], locations: ["Île-de-France"],
          revenue_min: 1_000_000, revenue_max: 10_000_000, investment: 5_000_000,
          formation: "Sciences Po + EM Lyon", experience: "Fonds d'investissement 10 ans",
          skills: "Analyse financière, Stratégie, Restructuration"
        },
        {
          first_name: "Isabelle", last_name: "Roche", buyer_type: :individual,
          subscription_plan: :standard, verified: false,
          sectors: ["Hospitality"], locations: ["Paris", "Hauts-de-Seine"],
          revenue_min: 400_000, revenue_max: 1_500_000, investment: 600_000,
          formation: "École hôtelière Lausanne", experience: "12 ans chef de cuisine",
          skills: "Cuisine gastronomique, Management, Œnologie"
        },
        {
          first_name: "Thomas", last_name: "Bernard", buyer_type: :investor,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Commerce", "Real Estate"], locations: ["Paris", "Lyon"],
          revenue_min: 500_000, revenue_max: 3_000_000, investment: 2_000_000,
          formation: "EDHEC Business School", experience: "Business Angel - 25 participations",
          skills: "Investissement, Conseil stratégique, Développement"
        },
        {
          first_name: "Caroline", last_name: "Petit", buyer_type: :individual,
          subscription_plan: :starter, verified: false,
          sectors: ["Hospitality", "Commerce"], locations: ["Paris"],
          revenue_min: 300_000, revenue_max: 1_000_000, investment: 400_000,
          formation: "BTS Hôtellerie-Restauration", experience: "8 ans directeur restaurant",
          skills: "Gestion opérationnelle, Service client, Gestion stocks"
        },
        {
          first_name: "Vincent", last_name: "Moreau", buyer_type: :holding,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Services", "Healthcare"], locations: ["Île-de-France", "Provence-Alpes-Côte d'Azur"],
          revenue_min: 1_000_000, revenue_max: 8_000_000, investment: 4_000_000,
          formation: "Dauphine + MBA INSEAD", experience: "Holding familiale - 8 entreprises",
          skills: "Consolidation, Synergies, Gouvernance"
        },
        {
          first_name: "Julia", last_name: "Rousseau", buyer_type: :individual,
          subscription_plan: :standard, verified: false,
          sectors: ["Hospitality"], locations: ["Paris", "Bordeaux"],
          revenue_min: 600_000, revenue_max: 2_500_000, investment: 800_000,
          formation: "Master Management du Luxe", experience: "10 ans sommelier chef",
          skills: "Œnologie, Gastronomie, Luxe"
        },
        {
          first_name: "Alexandre", last_name: "Leroy", buyer_type: :fund,
          subscription_plan: :club, verified: true,
          sectors: ["Hospitality", "Commerce", "Digital"], locations: ["Paris", "Lyon", "Toulouse"],
          revenue_min: 2_000_000, revenue_max: 15_000_000, investment: 10_000_000,
          formation: "Polytechnique + HEC", experience: "Fonds LBO - 15 acquisitions",
          skills: "LBO, Finance structurée, Optimisation"
        },
        {
          first_name: "Nathalie", last_name: "Faure", buyer_type: :individual,
          subscription_plan: :free, verified: false,
          sectors: ["Hospitality", "Commerce"], locations: ["Paris"],
          revenue_min: 200_000, revenue_max: 800_000, investment: 300_000,
          formation: "CAP Cuisine", experience: "5 ans sous-chef",
          skills: "Cuisine française, Pâtisserie"
        },
        {
          first_name: "Olivier", last_name: "Garnier", buyer_type: :investor,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Services"], locations: ["Île-de-France"],
          revenue_min: 800_000, revenue_max: 4_000_000, investment: 2_500_000,
          formation: "EM Lyon", experience: "Family Office - Gestion patrimoine",
          skills: "Investissement patrimonial, Fiscalité, Transmission"
        },
        {
          first_name: "Céline", last_name: "Blanc", buyer_type: :holding,
          subscription_plan: :standard, verified: false,
          sectors: ["Hospitality", "Commerce", "Services"], locations: ["Paris", "Nantes"],
          revenue_min: 500_000, revenue_max: 3_000_000, investment: 1_500_000,
          formation: "ESCP Europe", experience: "Groupe restauration - 5 établissements",
          skills: "Multi-sites, Concepts, Développement"
        },
        {
          first_name: "Fabien", last_name: "Mercier", buyer_type: :individual,
          subscription_plan: :starter, verified: false,
          sectors: ["Hospitality"], locations: ["Paris", "Lyon"],
          revenue_min: 400_000, revenue_max: 1_800_000, investment: 700_000,
          formation: "Licence Gestion", experience: "7 ans gérant brasserie",
          skills: "Gestion brasserie, Approvisionnement, RH"
        },
        {
          first_name: "Sandrine", last_name: "Girard", buyer_type: :individual,
          subscription_plan: :premium, verified: true,
          sectors: ["Hospitality", "Services"], locations: ["Paris"],
          revenue_min: 600_000, revenue_max: 2_000_000, investment: 900_000,
          formation: "École Ferrandi", experience: "Chef pâtissier 12 ans",
          skills: "Haute pâtisserie, Créativité, Excellence"
        },
        {
          first_name: "Maxime", last_name: "Fontaine", buyer_type: :fund,
          subscription_plan: :club, verified: true,
          sectors: ["Hospitality", "Commerce", "Services", "Digital"], locations: ["National"],
          revenue_min: 1_500_000, revenue_max: 20_000_000, investment: 15_000_000,
          formation: "HEC + CFA", experience: "Fonds infrastructure - 20 deals",
          skills: "Structuration deals, Valorisation, Exits"
        }
      ]
      
      created_buyers = []
      
      buyer_data.each_with_index do |data, index|
        # Remove accents from names for email
        first_name_clean = data[:first_name].parameterize.gsub('-', '')
        last_name_clean = data[:last_name].parameterize.gsub('-', '')
        email = "#{first_name_clean}.#{last_name_clean}@buyer#{index + 1}.fr"
        
        user = User.find_or_create_by!(email: email) do |u|
          u.password = 'password123'
          u.first_name = data[:first_name]
          u.last_name = data[:last_name]
          u.phone = "06#{rand(10_000_000..99_999_999)}"
          u.role = :buyer
          u.status = :active
        end
        
        # Create or update buyer profile
        buyer_profile = user.buyer_profile || user.create_buyer_profile!
        
        buyer_profile.update!(
          buyer_type: data[:buyer_type],
          subscription_plan: data[:subscription_plan],
          subscription_status: data[:subscription_plan] == :free ? :inactive : :active,
          subscription_expires_at: data[:subscription_plan] == :free ? nil : rand(30..365).days.from_now,
          verified_buyer: data[:verified],
          profile_status: :published,
          
          formation: data[:formation],
          experience: data[:experience],
          skills: data[:skills],
          investment_thesis: "Recherche d'opportunités dans le secteur de la restauration pour développement de patrimoine",
          
          target_sectors: data[:sectors],
          target_locations: data[:locations],
          target_revenue_min: data[:revenue_min],
          target_revenue_max: data[:revenue_max],
          target_employees_min: 5,
          target_employees_max: 50,
          target_financial_health: :in_bonis,
          target_horizon: "6-12 mois",
          target_transfer_types: ["total_shares", "partial_shares"],
          target_customer_types: ["b2c", "mixed"],
          
          investment_capacity: data[:investment],
          funding_sources: "Apport personnel + Financement bancaire",
          
          credits: rand(5..50),
          completeness_score: rand(60..98)
        )
        
        created_buyers << buyer_profile
        puts "  ✓ Created/Updated buyer: #{user.full_name} (#{data[:buyer_type]}, #{data[:subscription_plan]}#{data[:verified] ? ', verified' : ''})"
      end
      
      # ====================
      # STEP 3: Create favorites
      # ====================
      puts "\n❤️  Step 3: Creating favorites..."
      
      # Select 12 buyers to favorite the listing
      favoriting_buyers = created_buyers.shuffle.take(12)
      
      favoriting_buyers.each_with_index do |buyer_profile, index|
        favorite = Favorite.find_or_create_by!(
          buyer_profile: buyer_profile,
          listing: listing
        ) do |f|
          f.created_at = rand(1..60).days.ago
          f.updated_at = f.created_at
        end
        
        # Update created_at in database if it exists
        if !favorite.new_record?
          favorite.update_column(:created_at, rand(1..60).days.ago)
        end
        
        puts "  ✓ #{buyer_profile.user.full_name} favorited the listing"
      end
      
      # ====================
      # STEP 4: Create listing views
      # ====================
      puts "\n👁️  Step 4: Creating listing views..."
      
      views_count = 0
      
      # Create 80 views spread over 60 days
      80.times do
        days_ago = rand(1..60)
        hours_ago = rand(0..23)
        
        # 60% authenticated, 40% anonymous
        if rand < 0.6 && !created_buyers.empty?
          # Authenticated view
          buyer_profile = created_buyers.sample
          user = buyer_profile.user
          
          listing.listing_views.create!(
            user: user,
            viewed_at: days_ago.days.ago + hours_ago.hours,
            ip_address: "192.168.#{rand(1..255)}.#{rand(1..255)}",
            created_at: days_ago.days.ago + hours_ago.hours
          )
        else
          # Anonymous view
          listing.listing_views.create!(
            user: nil,
            viewed_at: days_ago.days.ago + hours_ago.hours,
            ip_address: "82.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
            created_at: days_ago.days.ago + hours_ago.hours
          )
        end
        
        views_count += 1
      end
      
      puts "  ✓ Created #{views_count} listing views (authenticated + anonymous)"
      
      # ====================
      # STEP 5: Create deals in various CRM stages
      # ====================
      puts "\n🤝 Step 5: Creating deals in various CRM stages..."
      
      # Select 10 buyers for deals (some may have favorited, some may not)
      deal_buyers = created_buyers.shuffle.take(10)
      
      deal_stages = [
        { status: :favorited, days: 5 },
        { status: :to_contact, days: 10 },
        { status: :to_contact, days: 8 },
        { status: :info_exchange, days: 15 },
        { status: :info_exchange, days: 12 },
        { status: :analysis, days: 20 },
        { status: :project_alignment, days: 25 },
        { status: :negotiation, days: 30 },
        { status: :loi, days: 35 },
        { status: :audits, days: 40 }
      ]
      
      deal_buyers.each_with_index do |buyer_profile, index|
        stage_info = deal_stages[index]
        
        deal = Deal.find_or_create_by!(
          buyer_profile: buyer_profile,
          listing: listing
        ) do |d|
          d.status = stage_info[:status]
          d.notes = "Profil intéressant - #{buyer_profile.buyer_type}. Projet en cours d'analyse."
          d.reserved = [:negotiation, :loi, :audits].include?(stage_info[:status])
          d.reserved_at = [:negotiation, :loi, :audits].include?(stage_info[:status]) ? stage_info[:days].days.ago : nil
          d.reserved_until = d.reserved ? 20.days.from_now : nil
          d.created_at = stage_info[:days].days.ago
          d.updated_at = rand(1..5).days.ago
        end
        
        # Update timestamps if deal already exists
        if !deal.new_record?
          deal.update_columns(
            status: Deal.statuses[stage_info[:status]],
            created_at: stage_info[:days].days.ago,
            reserved: [:negotiation, :loi, :audits].include?(stage_info[:status]),
            reserved_at: [:negotiation, :loi, :audits].include?(stage_info[:status]) ? stage_info[:days].days.ago : nil
          )
        end
        
        puts "  ✓ Created deal: #{buyer_profile.user.full_name} - Status: #{stage_info[:status]}"
      end
      
      # ====================
      # STEP 6: Update listing metrics
      # ====================
      puts "\n📊 Step 6: Updating listing metrics..."
      
      listing.update_column(:views_count, views_count)
      
      puts "  ✓ Updated listing views_count: #{views_count}"
      puts "  ✓ Total favorites: #{listing.favorites.count}"
      puts "  ✓ Total active deals: #{listing.deals.active.count}"
      
      # ====================
      # SUMMARY
      # ====================
      puts "\n✅ Analytics data seeding completed successfully!"
      puts "\n📈 Summary for Listing #24:"
      puts "  📋 Title: #{listing.title}"
      puts "  👁️  Total Views: #{listing.views_count}"
      puts "  ❤️  Favorites: #{listing.favorites.count}"
      puts "  🤝 Active Deals: #{listing.deals.active.count}"
      puts "  💼 Buyers Created: #{created_buyers.count}"
      puts "\n🔗 View analytics at: http://localhost:3000/seller/listings/24/analytics"
      puts "\n💡 Login as seller: #{seller_user.email} / password123"
      
      puts "\n📊 Deals by CRM Stage:"
      listing.deals.active.group(:status).count.each do |status, count|
        puts "  #{status}: #{count}"
      end
      
    rescue => e
      puts "\n❌ Error during analytics seeding: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      raise e
    end
  end
end
