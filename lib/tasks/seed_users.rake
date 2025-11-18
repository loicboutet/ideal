# frozen_string_literal: true

namespace :db do
  desc "Seed users and roles for BRICK 1 - Marketplace & Basic CRM"
  task seed_users: :environment do
    puts "\n🌱 Starting user seeding for BRICK 1 - Marketplace & Basic CRM..."
    
    # Track creation counts
    created_counts = { admin: 0, seller: 0, buyer: 0, partner: 0 }
    
    begin
      User.transaction do
        # ====================
        # ADMIN USERS (2-3)
        # ====================
        puts "\n👑 Creating Admin users..."
        
        admin_users = [
          {
            email: 'admin@ideal-reprise.fr',
            password: 'password123',
            first_name: 'Sophie',
            last_name: 'Dubois',
            role: :admin,
            status: :active
          },
          {
            email: 'operations@ideal-reprise.fr',
            password: 'password123',
            first_name: 'Laurent',
            last_name: 'Martin',
            role: :admin,
            status: :active
          },
          {
            email: 'support@ideal-reprise.fr',
            password: 'password123',
            first_name: 'Marie',
            last_name: 'Leroy',
            role: :admin,
            status: :active
          }
        ]
        
        admin_users.each do |user_attrs|
          unless User.exists?(email: user_attrs[:email])
            user = User.create!(user_attrs)
            created_counts[:admin] += 1
            puts "  ✓ Created admin: #{user.full_name} (#{user.email})"
          else
            puts "  ⚠ Admin already exists: #{user_attrs[:email]}"
          end
        end
        
        # ====================
        # SELLER USERS (5-7)
        # ====================
        puts "\n🏢 Creating Seller users..."
        
        seller_users = [
          {
            email: 'jean.dupont@entreprise.fr',
            password: 'password123',
            first_name: 'Jean',
            last_name: 'Dupont',
            phone: '0145236789',
            company_name: 'Boulangerie Dupont',
            role: :seller,
            status: :active
          },
          {
            email: 'marie.bernard@tech.fr',
            password: 'password123',
            first_name: 'Marie',
            last_name: 'Bernard',
            phone: '0298764532',
            company_name: 'TechConseil SARL',
            role: :seller,
            status: :active
          },
          {
            email: 'philippe.moreau@transport.fr',
            password: 'password123',
            first_name: 'Philippe',
            last_name: 'Moreau',
            phone: '0467891234',
            company_name: 'Transport Moreau & Fils',
            role: :seller,
            status: :active
          },
          {
            email: 'claire.lambert@resto.fr',
            password: 'password123',
            first_name: 'Claire',
            last_name: 'Lambert',
            phone: '0387654321',
            company_name: 'Restaurant Le Grand Chef',
            role: :seller,
            status: :pending
          },
          {
            email: 'alain.rousseau@industrie.fr',
            password: 'password123',
            first_name: 'Alain',
            last_name: 'Rousseau',
            phone: '0556789012',
            company_name: 'Rousseau Métallurgie',
            role: :seller,
            status: :active
          },
          {
            email: 'nathalie.petit@commerce.fr',
            password: 'password123',
            first_name: 'Nathalie',
            last_name: 'Petit',
            phone: '0412345678',
            company_name: 'Boutique Mode & Style',
            role: :seller,
            status: :active
          }
        ]
        
        seller_users.each do |user_attrs|
          unless User.exists?(email: user_attrs[:email])
            user = User.create!(user_attrs)
            created_counts[:seller] += 1
            puts "  ✓ Created seller: #{user.full_name} - #{user.company_name} (#{user.email})"
          else
            puts "  ⚠ Seller already exists: #{user_attrs[:email]}"
          end
        end
        
        # ====================
        # BUYER USERS (8-10)
        # ====================
        puts "\n💼 Creating Buyer users..."
        
        buyer_users = [
          {
            email: 'thomas.garcia@repreneur.fr',
            password: 'password123',
            first_name: 'Thomas',
            last_name: 'Garcia',
            phone: '0623456789',
            role: :buyer,
            status: :active
          },
          {
            email: 'isabelle.roux@invest.fr',
            password: 'password123',
            first_name: 'Isabelle',
            last_name: 'Roux',
            phone: '0734567890',
            role: :buyer,
            status: :active
          },
          {
            email: 'pierre.david@holdings.fr',
            password: 'password123',
            first_name: 'Pierre',
            last_name: 'David',
            phone: '0645678901',
            role: :buyer,
            status: :active
          },
          {
            email: 'sandrine.michel@acquisition.fr',
            password: 'password123',
            first_name: 'Sandrine',
            last_name: 'Michel',
            phone: '0556789012',
            role: :buyer,
            status: :active
          },
          {
            email: 'vincent.thomas@fonds.fr',
            password: 'password123',
            first_name: 'Vincent',
            last_name: 'Thomas',
            phone: '0467890123',
            role: :buyer,
            status: :active
          },
          {
            email: 'caroline.robert@business.fr',
            password: 'password123',
            first_name: 'Caroline',
            last_name: 'Robert',
            phone: '0378901234',
            role: :buyer,
            status: :pending
          },
          {
            email: 'julien.richard@venture.fr',
            password: 'password123',
            first_name: 'Julien',
            last_name: 'Richard',
            phone: '0689012345',
            role: :buyer,
            status: :active
          },
          {
            email: 'agnes.durand@capital.fr',
            password: 'password123',
            first_name: 'Agnès',
            last_name: 'Durand',
            phone: '0290123456',
            role: :buyer,
            status: :active
          },
          {
            email: 'francois.simon@individual.fr',
            password: 'password123',
            first_name: 'François',
            last_name: 'Simon',
            phone: '0512345678',
            role: :buyer,
            status: :suspended
          }
        ]
        
        buyer_users.each do |user_attrs|
          unless User.exists?(email: user_attrs[:email])
            user = User.create!(user_attrs)
            created_counts[:buyer] += 1
            puts "  ✓ Created buyer: #{user.full_name} (#{user.email})"
          else
            puts "  ⚠ Buyer already exists: #{user_attrs[:email]}"
          end
        end
        
        # ====================
        # PARTNER USERS (4-6)
        # ====================
        puts "\n🤝 Creating Partner users..."
        
        partner_users = [
          {
            email: 'cabinet.avocat@juridique.fr',
            password: 'password123',
            first_name: 'Maître Anne',
            last_name: 'Lefevre',
            phone: '0145678901',
            company_name: 'Cabinet Juridique Lefevre & Associés',
            role: :partner,
            status: :active,
            partner_type: :lawyer
          },
          {
            email: 'expertise.comptable@fiduciaire.fr',
            password: 'password123',
            first_name: 'Jean-Claude',
            last_name: 'Moreau',
            phone: '0234567890',
            company_name: 'Fiduciaire Moreau Expertise',
            role: :partner,
            status: :active,
            partner_type: :accountant
          },
          {
            email: 'conseil.strategie@consulting.fr',
            password: 'password123',
            first_name: 'Valérie',
            last_name: 'Fournier',
            phone: '0345678901',
            company_name: 'Fournier Conseil & Stratégie',
            role: :partner,
            status: :pending,
            partner_type: :consultant
          },
          {
            email: 'banque.affaires@finance.fr',
            password: 'password123',
            first_name: 'Michel',
            last_name: 'Girard',
            phone: '0456789012',
            company_name: 'Girard Finance - Banque d\'Affaires',
            role: :partner,
            status: :active,
            partner_type: :banker
          },
          {
            email: 'courtage.entreprises@broker.fr',
            password: 'password123',
            first_name: 'Sylvie',
            last_name: 'Blanchard',
            phone: '0567890123',
            company_name: 'Blanchard Courtage Entreprises',
            role: :partner,
            status: :active,
            partner_type: :broker
          },
          {
            email: 'audit.conseil@expertise.fr',
            password: 'password123',
            first_name: 'Pascal',
            last_name: 'Mercier',
            phone: '0678901234',
            company_name: 'Mercier Audit & Conseil',
            role: :partner,
            status: :active,
            partner_type: :consultant
          }
        ]
        
        partner_users.each do |user_attrs|
          unless User.exists?(email: user_attrs[:email])
            # Extract partner-specific attributes
            partner_type = user_attrs.delete(:partner_type)
            
            # Temporarily disable the after_create callback
            User.skip_callback(:create, :after, :create_profile)
            
            # Create user without automatic profile creation
            user = User.create!(user_attrs)
            
            # Re-enable the callback
            User.set_callback(:create, :after, :create_profile)
            
            # Manually create partner profile with required fields
            user.create_partner_profile!(
              partner_type: partner_type,
              validation_status: :approved,
              coverage_area: :department,
              description: "#{user.company_name} - Services professionnels de qualité",
              services_offered: "Conseil, accompagnement et expertise dans le domaine des reprises d'entreprises",
              website: "https://www.#{user.email.split('@').first.gsub('.', '-')}.com",
              directory_subscription_expires_at: 1.year.from_now
            )
            
            created_counts[:partner] += 1
            puts "  ✓ Created partner: #{user.full_name} - #{user.company_name} (#{user.email}) [#{partner_type}]"
          else
            puts "  ⚠ Partner already exists: #{user_attrs[:email]}"
          end
        end
        
        # ====================
        # SUMMARY
        # ====================
        puts "\n📊 User Creation Summary:"
        puts "  👑 Admins: #{created_counts[:admin]} created"
        puts "  🏢 Sellers: #{created_counts[:seller]} created"
        puts "  💼 Buyers: #{created_counts[:buyer]} created"
        puts "  🤝 Partners: #{created_counts[:partner]} created"
        puts "  📈 Total: #{created_counts.values.sum} users created"
        
        puts "\n📈 Current User Statistics:"
        puts "  👑 Total Admins: #{User.admins.count}"
        puts "  🏢 Total Sellers: #{User.sellers.count}"
        puts "  💼 Total Buyers: #{User.buyers.count}"
        puts "  🤝 Total Partners: #{User.partners.count}"
        puts "  👥 Total Users: #{User.count}"
        puts "  ✅ Active Users: #{User.active_users.count}"
        puts "  ⏳ Pending Users: #{User.where(status: :pending).count}"
        puts "  ⛔ Suspended Users: #{User.where(status: :suspended).count}"
        
        puts "\n✅ User seeding completed successfully!"
        puts "\n💡 Default password for all users: password123"
        puts "💡 You can now login with any of the created user emails"
        
      end
      
    rescue => e
      puts "\n❌ Error during user seeding: #{e.message}"
      puts e.backtrace.first
      raise e
    end
  end
end
