# frozen_string_literal: true

namespace :db do
  namespace :seed do
    desc "Seed listing analytics data (views, favorites, deals)"
    task listing_analytics: :environment do
      puts "🔄 Seeding listing analytics data..."
      
      # Find sellers and buyers
      sellers = User.where(role: :seller).includes(:seller_profile).limit(3)
      buyers = User.where(role: :buyer).includes(:buyer_profile).limit(10)
      
      if sellers.empty? || buyers.empty?
        puts "⚠️  No sellers or buyers found. Please seed users first."
        next
      end
      
      # Track counts
      views_created = 0
      favorites_created = 0
      deals_created = 0
      
      sellers.each do |seller|
        seller.seller_profile.listings.approved.each do |listing|
          puts "  📊 Adding analytics for listing: #{listing.title}"
          
          # Generate views from random buyers over the past 30 days
          view_count = rand(50..300)
          view_count.times do
            buyer = buyers.sample
            days_ago = rand(1..30)
            
            begin
              ListingView.create!(
                listing: listing,
                user: buyer,
                ip_address: "192.168.1.#{rand(1..255)}",
                viewed_at: days_ago.days.ago + rand(0..23).hours
              )
              views_created += 1
            rescue ActiveRecord::RecordNotUnique
              # Skip duplicates
            end
          end
          
          # Update listing views_count to match
          listing.update_column(:views_count, listing.listing_views.count)
          
          # Create some favorites (20-40% of viewers)
          favorite_count = (view_count * rand(0.2..0.4)).to_i
          buyers.sample(favorite_count).each do |buyer|
            begin
              Favorite.create!(
                buyer_profile: buyer.buyer_profile,
                listing: listing,
                created_at: rand(1..25).days.ago
              )
              favorites_created += 1
            rescue ActiveRecord::RecordInvalid
              # Skip if already exists
            end
          end
          
          # Create some deals in various CRM stages (10-20% of viewers)
          deal_count = (view_count * rand(0.1..0.2)).to_i
          statuses = [:favorited, :to_contact, :info_exchange, :analysis, :project_alignment, :negotiation]
          
          buyers.sample(deal_count).each do |buyer|
            begin
              status = statuses.sample
              Deal.create!(
                buyer_profile: buyer.buyer_profile,
                listing: listing,
                status: status,
                reserved: [:to_contact, :info_exchange, :negotiation].include?(status),
                reserved_at: status == :to_contact ? rand(1..7).days.ago : nil,
                reserved_until: status == :to_contact ? rand(1..7).days.from_now : nil,
                stage_entered_at: rand(1..20).days.ago,
                created_at: rand(1..25).days.ago
              )
              deals_created += 1
            rescue ActiveRecord::RecordInvalid
              # Skip if already exists
            end
          end
          
          puts "    ✅ Added #{listing.listing_views.count} views, #{listing.favorites.count} favorites, #{listing.deals.count} deals"
        end
      end
      
      puts "\n✨ Listing analytics seeding complete!"
      puts "   📈 Created #{views_created} listing views"
      puts "   ⭐ Created #{favorites_created} favorites"
      puts "   🤝 Created #{deals_created} deals"
      puts "\n💡 View analytics at: /seller/dashboard"
    end
  end
end
