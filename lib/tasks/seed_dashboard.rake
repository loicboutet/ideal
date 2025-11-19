# frozen_string_literal: true

namespace :db do
  desc "Seed comprehensive data for Admin Dashboard Operations Center"
  task seed_dashboard: :environment do
    puts "\n🎯 Starting Admin Dashboard Data Seeding..."
    puts "=" * 60
    
    # ====================
    # STEP 1: Ensure base users exist
    # ====================
    puts "\n👥 Step 1: Ensuring base users exist..."
    
    # Create admin if doesn't exist
    admin = User.find_or_create_by!(email: 'admin@ideal-reprise.fr') do |u|
      u.password = 'password123'
      u.first_name = 'Admin'
      u.last_name = 'Idéal Reprise'
      u.role = :admin
      u.status = :active
    end
    puts "  ✓ Admin user ready: #{admin.email}"
    
    # Ensure we have sellers, buyers, and partners
    seller_count = SellerProfile.count
    buyer_count = BuyerProfile.count
    partner_count = PartnerProfile.count
    
    if seller_count < 3 || buyer_count < 10 || partner_count < 3
      puts "  ⚠️  Insufficient base users. Running seed_users first..."
      Rake::Task['db:seed_users'].invoke
    end
    
    puts "  ✓ Base users ready: #{User.sellers.count} sellers, #{User.buyers.count} buyers, #{User.partners.count} partners"
    
    # ====================
    # STEP 2: Create diverse listings
    # ====================
    puts "\n📋 Step 2: Creating diverse listings for dashboard metrics..."
    
    sellers = SellerProfile.all.to_a
    
    # Business types
    business_types = [
      'Restaurant gastronomique', 'Boulangerie-pâtisserie', 'Salon de coiffure',
      'Garage automobile', 'Agence web', 'Cabinet comptable', 'Pressing',
      'Bar à vins', 'Épicerie fine', 'Salle de sport', 'Pharmacie',
      'Chocolaterie', 'Auto-école', 'Boutique vêtements', 'Brasserie'
    ]
    
    sectors = Listing.industry_sectors.keys
    departments = ['75', '69', '31', '33', '59', '13', '44', '67', '35', '06']
    
    # Create 30 listings with specific characteristics
    listing_configs = [
      # Approved & Published with 0 views (for zero view alert)
      { count: 5, validation: :approved, status: :published, views: 0 },
      # Approved & Published with views
      { count: 10, validation: :approved, status: :published, views: (10..100) },
      # Pending validation (for pending validations alert)
      { count: 8, validation: :pending, status: :published, views: 0 },
      # Draft listings
      { count: 4, validation: :pending, status: :draft, views: 0 },
      # Rejected listings
      { count: 3, validation: :rejected, status: :draft, views: 0 }
    ]
    
    created_listings = []
    
    listing_configs.each do |config|
      config[:count].times do
        seller = sellers.sample
        
        annual_revenue = rand(200_000..3_000_000)
        views = config[:views].is_a?(Range) ? rand(config[:views]) : config[:views]
        
        listing = seller.listings.create!(
          title: business_types.sample,
          industry_sector: sectors.sample,
          location_department: departments.sample,
          location_region: 'Île-de-France',
          location_city: 'Paris',
          
          description_public: "Entreprise bien établie avec clientèle fidèle. Opportunité de reprise intéressante.",
          description_confidential: "Détails confidentiels disponibles après NDA.",
          
          annual_revenue: annual_revenue,
          net_profit: (annual_revenue * rand(0.05..0.20)).round,
          employee_count: rand(2..25),
          company_age: rand(3..20),
          
          asking_price: (annual_revenue * rand(0.8..1.5)).round,
          transfer_horizon: ['Immédiat (moins de 6 mois)', '6-12 mois', '1-2 ans'].sample,
          transfer_type: Listing.transfer_types.keys.sample,
          customer_type: Listing.customer_types.keys.sample,
          legal_form: ['SARL', 'SAS', 'EURL'].sample,
          
          deal_type: ['direct', 'ideal_mandate', 'partner_mandate'].sample,
          status: config[:status],
          validation_status: config[:validation],
          
          views_count: views,
          completeness_score: rand(50..95),
          
          submitted_at: config[:validation] == :pending ? rand(1..30).days.ago : rand(10..90).days.ago,
          validated_at: config[:validation] == :approved ? rand(5..60).days.ago : nil,
          created_at: rand(30..180).days.ago
        )
        
        created_listings << listing if config[:validation] == :approved && config[:status] == :published
      end
    end
    
    total_listings = Listing.count
    puts "  ✓ Created listings - Total in DB: #{total_listings}"
    puts "    - Approved & Published: #{Listing.where(validation_status: :approved, status: :published).count}"
    puts "    - Pending Validation: #{Listing.where(validation_status: :pending).count}"
    puts "    - Zero Views: #{Listing.where(validation_status: :approved, status: :published).where('views_count = 0 OR views_count IS NULL').count}"
    
    # ====================
    # STEP 3: Create buyers with active subscriptions
    # ====================
    puts "\n💼 Step 3: Ensuring buyers with active subscriptions..."
    
    buyer_profiles = BuyerProfile.all.to_a
    
    # Ensure at least 10 have active subscriptions for the ratio calculation
    active_buyers = 0
    buyer_profiles.each do |buyer|
      if active_buyers < 10
        buyer.update!(
          subscription_plan: [:starter, :standard, :premium, :club].sample,
          subscription_status: :active,
          subscription_expires_at: rand(30..365).days.from_now
        )
        active_buyers += 1
      end
    end
    
    puts "  ✓ Active paying buyers: #{BuyerProfile.where(subscription_status: :active).count}"
    
    # ====================
    # STEP 4: Create deals across all CRM stages
    # ====================
    puts "\n🤝 Step 4: Creating deals across all 10 CRM stages..."
    
    # Select approved published listings for deals
    available_listings = created_listings.select { |l| l.views_count.to_i > 0 }.take(20)
    
    if available_listings.empty?
      puts "  ⚠️  No available listings for deals"
    else
      deal_distributions = [
        { status: :favorited, count: 5, reserved: false, days_ago: 3 },
        { status: :to_contact, count: 4, reserved: true, days_ago: 8, timer_days: 7 },
        { status: :info_exchange, count: 3, reserved: true, days_ago: 15, timer_days: 33 },
        { status: :analysis, count: 3, reserved: true, days_ago: 22, timer_days: 33 },
        { status: :project_alignment, count: 2, reserved: true, days_ago: 28, timer_days: 33 },
        { status: :negotiation, count: 2, reserved: true, days_ago: 35, timer_days: 20 },
        { status: :loi, count: 1, reserved: true, days_ago: 40, timer_days: nil },
        { status: :audits, count: 1, reserved: true, days_ago: 50, timer_days: nil },
        { status: :financing, count: 1, reserved: true, days_ago: 60, timer_days: nil },
        { status: :signed, count: 1, reserved: false, days_ago: 70 },
        { status: :released, count: 3, reserved: false, days_ago: 45 },
        { status: :abandoned, count: 2, reserved: false, days_ago: 50 }
      ]
      
      deal_index = 0
      deal_distributions.each do |config|
        config[:count].times do
          break if deal_index >= available_listings.count || deal_index >= buyer_profiles.count
          
          listing = available_listings[deal_index]
          buyer = buyer_profiles[deal_index]
          
          created_at = config[:days_ago].days.ago
          reserved_at = config[:reserved] ? created_at : nil
          reserved_until = if config[:timer_days]
                            reserved_at + config[:timer_days].days
                          else
                            nil
                          end
          
          # For released/abandoned, set released_at
          released_at = [:released, :abandoned].include?(config[:status]) ? rand(1..10).days.ago : nil
          
          deal = Deal.create!(
            buyer_profile: buyer,
            listing: listing,
            status: config[:status],
            reserved: config[:reserved],
            reserved_at: reserved_at,
            reserved_until: reserved_until,
            released_at: released_at,
            notes: "Deal in #{config[:status]} stage",
            created_at: created_at,
            updated_at: rand(1..5).days.ago
          )
          
          deal_index += 1
        end
      end
      
      puts "  ✓ Created deals across all stages:"
      Deal.group(:status).count.each do |status, count|
        puts "    - #{status}: #{count}"
      end
    end
    
    # ====================
    # STEP 5: Create deals with EXPIRED timers
    # ====================
    puts "\n⏱️  Step 5: Creating deals with expired timers..."
    
    expired_count = 0
    if available_listings.count > deal_index && buyer_profiles.count > deal_index
      3.times do
        break if deal_index >= available_listings.count || deal_index >= buyer_profiles.count
        
        listing = available_listings[deal_index]
        buyer = buyer_profiles[deal_index]
        
        # Create deal with timer already expired
        Deal.create!(
          buyer_profile: buyer,
          listing: listing,
          status: [:to_contact, :negotiation].sample,
          reserved: true,
          reserved_at: 15.days.ago,
          reserved_until: rand(1..7).days.ago, # Already expired
          notes: "Timer expired - needs automatic release",
          created_at: 20.days.ago,
          updated_at: 10.days.ago
        )
        
        expired_count += 1
        deal_index += 1
      end
    end
    
    puts "  ✓ Created #{expired_count} deals with expired timers"
    
    # ====================
    # STEP 6: Create partner contacts for usage tracking
    # ====================
    puts "\n🤝 Step 6: Creating partner contacts for usage analytics..."
    
    partners = PartnerProfile.where(validation_status: :approved).to_a
    
    # Ensure some partners are approved
    if User.partners.count > 0 && partners.count < 3
      User.partners.limit(3).each do |partner_user|
        profile = partner_user.partner_profile
        profile.update!(
          validation_status: :approved,
          subscription_status: :active,
          subscription_expires_at: 1.year.from_now,
          views_count: rand(20..200)
        )
        partners << profile
      end
    end
    
    # Create partner contacts over last 6 months
    contact_count = 0
    if partners.any? && buyer_profiles.any?
      partners.each do |partner|
        # Random contacts spread over 6 months
        rand(3..15).times do
          month_ago = rand(0..5)
          day_in_month = rand(0..28)
          
          PartnerContact.create!(
            partner_profile: partner,
            user: buyer_profiles.sample.user,
            contact_type: [:view, :contact].sample,
            created_at: month_ago.months.ago + day_in_month.days
          )
          
          contact_count += 1
        end
        
        # Update views count
        partner.update_column(:views_count, rand(50..300))
      end
    end
    
    puts "  ✓ Created #{contact_count} partner contacts across #{partners.count} partners"
    
    # ====================
    # STEP 7: Create listing views for trending data
    # ====================
    puts "\n👁️  Step 7: Creating listing views for analytics..."
    
    view_count = 0
    created_listings.each do |listing|
      next if listing.views_count == 0
      
      # Create actual view records matching views_count
      target_views = [listing.views_count, 50].min # Cap at 50 to avoid too many records
      
      target_views.times do
        days_ago = rand(1..60)
        
        # 70% authenticated views
        if rand < 0.7 && buyer_profiles.any?
          buyer = buyer_profiles.sample
          ListingView.create!(
            listing: listing,
            user: buyer.user,
            viewed_at: days_ago.days.ago,
            ip_address: "192.168.#{rand(1..255)}.#{rand(1..255)}",
            created_at: days_ago.days.ago
          )
        else
          # Anonymous view
          ListingView.create!(
            listing: listing,
            user: nil,
            viewed_at: days_ago.days.ago,
            ip_address: "82.#{rand(1..255)}.#{rand(1..255)}.#{rand(1..255)}",
            created_at: days_ago.days.ago
          )
        end
        
        view_count += 1
      end
    end
    
    puts "  ✓ Created #{view_count} listing view records"
    
    # ====================
    # STEP 8: Ensure pending partners for validation alert
    # ====================
    puts "\n🔍 Step 8: Ensuring pending partners for validation..."
    
    pending_partners = PartnerProfile.where(validation_status: :pending).count
    if pending_partners < 3 && User.partners.count >= 3
      User.partners.limit(3).each do |partner_user|
        partner_user.partner_profile.update!(validation_status: :pending)
      end
    end
    
    puts "  ✓ Pending partners: #{PartnerProfile.where(validation_status: :pending).count}"
    
    # ====================
    # FINAL SUMMARY
    # ====================
    puts "\n" + "=" * 60
    puts "✅ Admin Dashboard Seeding Complete!"
    puts "=" * 60
    
    puts "\n📊 Dashboard Metrics Summary:"
    puts "\n🚨 Alert KPIs:"
    puts "  - Zero View Listings: #{Listing.where(validation_status: :approved, status: :published).where('views_count = 0 OR views_count IS NULL').count}"
    puts "  - Pending Validations: #{Listing.where(validation_status: :pending).count + PartnerProfile.where(validation_status: :pending).count}"
    puts "  - Pending Reports: 0 (placeholder)"
    puts "  - Expired Timers: #{Deal.active.where.not(reserved_until: nil).where('reserved_until < ?', Time.current).count}"
    
    puts "\n📈 Growth Metrics:"
    puts "  - Active Listings: #{Listing.where(validation_status: :approved, status: :published).count}"
    puts "  - Total Users: #{User.count}"
    puts "  - Active Buyers: #{BuyerProfile.where(subscription_status: :active).count}"
    puts "  - Reservations: #{Deal.where(reserved: true).count}"
    
    puts "\n🎯 Key Ratios:"
    available = Listing.where(validation_status: :approved, status: :published).count
    paying = BuyerProfile.where(subscription_status: :active).count
    ratio = paying.zero? ? 0 : (available.to_f / paying).round(2)
    puts "  - Listings/Buyer Ratio: #{ratio} (#{available} listings / #{paying} buyers)"
    
    puts "\n🤝 Deals by Status:"
    Deal.group(:status).count.each do |status, count|
      puts "  - #{status}: #{count}"
    end
    
    puts "\n👥 User Distribution:"
    User.group(:role).count.each do |role, count|
      puts "  - #{role}: #{count}"
    end
    
    puts "\n🏢 Partner Analytics:"
    puts "  - Total Views: #{PartnerProfile.sum(:views_count)}"
    puts "  - Total Contacts: #{PartnerContact.count}"
    puts "  - Active Partners: #{PartnerProfile.where(validation_status: :approved).count}"
    
    puts "\n🔗 Access Dashboard:"
    puts "  URL: http://localhost:3000/admin"
    puts "  Login: #{admin.email} / password123"
    puts "\n✨ All dashboard features should now display data!"
    puts "=" * 60
  end
end
