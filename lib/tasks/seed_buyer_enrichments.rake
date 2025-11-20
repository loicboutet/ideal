namespace :db do
  namespace :seed do
    desc "Seed buyer enrichments with dummy data"
    task buyer_enrichments: :environment do
      puts "🌱 Seeding buyer enrichments..."
      
      # Find or create a buyer user
      buyer_user = User.find_by(role: 'buyer') || User.create!(
        email: 'buyer@example.com',
        password: 'Password123!',
        password_confirmation: 'Password123!',
        role: 'buyer',
        first_name: 'Pierre',
        last_name: 'Martin',
        status: 'active'
      )
      
      # Ensure buyer profile exists
      buyer_profile = buyer_user.buyer_profile || buyer_user.create_buyer_profile!(
        company_name: 'Martin Investissements',
        target_sectors: ['Commerce', 'Services'],
        target_regions: ['Île-de-France', 'Provence-Alpes-Côte d\'Azur']
      )
      
      # Find approved listings
      listings = Listing.approved.limit(3)
      
      if listings.none?
        puts "⚠️  No approved listings found. Please seed listings first."
        exit
      end
      
      # Create deals for the buyer if they don't exist
      listings.each do |listing|
        unless buyer_profile.deals.exists?(listing: listing)
          buyer_profile.deals.create!(
            listing: listing,
            status: 'interested',
            notes: "Deal créé automatiquement pour les tests"
          )
        end
      end
      
      puts "  ✓ Created deals for #{listings.count} listings"
      
      # Enrichment categories to seed
      categories = [
        { category: 'balance_n1', description: 'Bilan financier année dernière' },
        { category: 'balance_n2', description: 'Bilan financier année N-2' },
        { category: 'org_chart', description: 'Structure organisationnelle complète' },
        { category: 'tax_return', description: 'Liasse fiscale complète' },
        { category: 'income_statement', description: 'Compte de résultat détaillé' }
      ]
      
      statuses = ['pending', 'approved', 'rejected']
      
      enrichments_created = 0
      
      listings.each_with_index do |listing, listing_index|
        # Create 2-3 enrichments per listing
        num_enrichments = [2, 3].sample
        
        num_enrichments.times do |i|
          category_data = categories[i % categories.length]
          status = statuses[i % statuses.length]
          
          enrichment = buyer_profile.enrichments.find_or_create_by!(
            listing: listing,
            document_category: category_data[:category]
          ) do |e|
            e.description = category_data[:description]
            e.validation_status = status
            e.validated = (status == 'approved')
            
            if status == 'approved'
              e.validated_at = Time.current - rand(1..10).days
              e.validated_by = listing.seller_profile.user
            elsif status == 'rejected'
              e.validated_at = Time.current - rand(1..5).days
              e.validated_by = listing.seller_profile.user
              e.rejection_reason = [
                "Format de document incorrect",
                "Informations incomplètes",
                "Document non lisible",
                "Données obsolètes"
              ].sample
            end
          end
          
          enrichments_created += 1
        end
      end
      
      puts "  ✓ Created #{enrichments_created} enrichments"
      puts "  ✓ Statuses: Pending, Approved, and Rejected"
      puts ""
      puts "✅ Buyer enrichments seeding completed!"
      puts ""
      puts "📊 Summary:"
      puts "  - Buyer: #{buyer_user.email}"
      puts "  - Deals created: #{buyer_profile.deals.count}"
      puts "  - Total enrichments: #{buyer_profile.enrichments.count}"
      puts "  - Pending: #{buyer_profile.enrichments.pending_validation.count}"
      puts "  - Approved: #{buyer_profile.enrichments.approved_enrichments.count}"
      puts "  - Rejected: #{buyer_profile.enrichments.rejected_enrichments.count}"
      puts ""
      puts "🌐 Access the enrichments at:"
      puts "  http://localhost:3000/buyer/enrichments"
      puts ""
      puts "🔑 Login credentials:"
      puts "  Email: #{buyer_user.email}"
      puts "  Password: Password123!"
    end
  end
end
