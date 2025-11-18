namespace :db do
  desc "Seed 10 listings for each seller with realistic data"
  task seed_listings: :environment do
    puts "🌱 Starting to seed listings for sellers..."
    
    sellers = SellerProfile.all
    
    if sellers.empty?
      puts "❌ No sellers found. Please run rake db:seed_users first."
      exit
    end
    
    # Sample data
    business_types = [
      'Boulangerie artisanale', 'Restaurant italien', 'Agence digitale',
      'Salon de coiffure', 'Pressing', 'Auto-école', 'Épicerie fine',
      'Bar à vins', 'Cabinet comptable', 'Garage automobile',
      'Boutique de vêtements', 'Salle de sport', 'Pharmacie',
      'Brasserie', 'Chocolaterie', 'Startup SaaS', 'E-commerce mode',
      'Cabinet médical', 'Laboratoire analyse', 'Entreprise BTP'
    ]
    
    sectors = Listing.industry_sectors.keys
    departments = ['75', '69', '31', '33', '59', '13', '44', '67', '35', '06']
    regions = ['Île-de-France', 'Auvergne-Rhône-Alpes', 'Occitanie', 'Nouvelle-Aquitaine', 
               'Hauts-de-France', 'Provence-Alpes-Côte d\'Azur', 'Pays de la Loire', 
               'Grand Est', 'Bretagne', 'Normandie']
    cities = ['Paris', 'Lyon', 'Toulouse', 'Bordeaux', 'Lille', 'Marseille', 
              'Nantes', 'Strasbourg', 'Rennes', 'Nice']
    
    transfer_horizons = ['Immédiat (moins de 6 mois)', '6-12 mois', '1-2 ans', '2-5 ans']
    legal_forms = ['SARL', 'SAS', 'EURL', 'SA', 'SCI']
    
    sellers.each do |seller|
      puts "\n👤 Creating listings for seller: #{seller.user.email}"
      
      10.times do |i|
        # Random business data
        annual_revenue = rand(200_000..5_000_000)
        net_profit = (annual_revenue * rand(0.05..0.25)).round
        asking_price = (annual_revenue * rand(0.5..2.0)).round
        employee_count = rand(1..50)
        company_age = rand(2..30)
        
        listing = seller.listings.create!(
          title: business_types.sample,
          industry_sector: sectors.sample,
          location_department: departments.sample,
          location_region: regions.sample,
          location_city: cities.sample,
          
          description_public: "Entreprise bien établie dans #{cities.sample} avec une clientèle fidèle. " \
                              "Activité rentable et pérenne. Excellent emplacement commercial. " \
                              "Possibilité de développement important.",
          
          description_confidential: "Informations détaillées disponibles après signature de l'accord de confidentialité. " \
                                   "Raisons de cession: départ à la retraite. Locaux en bon état. " \
                                   "Équipements récents. Contrats fournisseurs en place.",
          
          annual_revenue: annual_revenue,
          net_profit: net_profit,
          employee_count: employee_count,
          company_age: company_age,
          
          asking_price: asking_price,
          price_min: (asking_price * 0.9).round,
          price_max: (asking_price * 1.1).round,
          
          transfer_horizon: transfer_horizons.sample,
          transfer_type: Listing.transfer_types.keys.sample,
          customer_type: Listing.customer_types.keys.sample,
          legal_form: legal_forms.sample,
          
          deal_type: ['direct', 'ideal_mandate', 'partner_mandate'].sample,
          
          # Mix of statuses and validation states
          status: ['draft', 'published'].sample,
          validation_status: ['pending', 'approved'].sample,
          
          views_count: rand(0..500),
          completeness_score: rand(40..95),
          
          submitted_at: rand(1..90).days.ago,
          created_at: rand(1..180).days.ago
        )
        
        # Add some views for approved listings
        if listing.validation_status == 'approved' && rand < 0.7
          view_count = rand(5..50)
          view_count.times do
            listing.listing_views.create!(
              viewed_at: rand(1..60).days.ago,
              ip_address: "192.168.1.#{rand(1..255)}",
              created_at: rand(1..60).days.ago
            )
          end
        end
        
        print "."
      end
      
      puts "\n✅ Created 10 listings for #{seller.user.email}"
    end
    
    total_listings = Listing.count
    puts "\n🎉 Seeding complete! Total listings in database: #{total_listings}"
    puts "\n📊 Listing breakdown by status:"
    Listing.group(:validation_status).count.each do |status, count|
      puts "   #{status}: #{count}"
    end
  end
end
