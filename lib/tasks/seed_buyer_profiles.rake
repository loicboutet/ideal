# frozen_string_literal: true

namespace :db do
  desc "Seed buyer profiles for the Seller Buyers Directory"
  task seed_buyer_profiles: :environment do
    puts "\n🌱 Starting buyer profile seeding..."
    
    created_count = 0
    updated_count = 0
    
    begin
      BuyerProfile.transaction do
        # Find all buyer users
        buyer_users = User.where(role: :buyer, status: :active)
        
        if buyer_users.empty?
          puts "\n⚠️  No active buyer users found. Please run 'rails db:seed_users' first."
          exit
        end
        
        # Define buyer profile templates
        buyer_profiles_data = [
          {
            buyer_type: :individual,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 150,
            formation: "MBA INSEAD, Master Finance HEC Paris",
            experience: "15 ans d'expérience en direction générale, ancien DG de PME industrielle (50M€ CA)",
            skills: "Management, restructuration d'entreprises, développement commercial, industrie 4.0",
            investment_thesis: "Recherche PME industrielle ou technologique à fort potentiel de croissance. Expertise en transformation digitale et développement international.",
            target_sectors: ["Industrie", "Technologies", "Services B2B"],
            target_locations: ["Île-de-France", "Auvergne-Rhône-Alpes", "Nouvelle-Aquitaine"],
            target_revenue_min: 2_000_000,
            target_revenue_max: 15_000_000,
            target_employees_min: 15,
            target_employees_max: 100,
            target_transfer_types: ["Cession totale", "Cession partielle"],
            target_customer_types: ["B2B", "B2B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Reprise immédiate (3-6 mois)",
            investment_capacity: "2M€ - 5M€",
            funding_sources: "Apport personnel (40%), Crédit bancaire (40%), Investisseur (20%)",
            subscription_expires_at: 6.months.from_now
          },
          {
            buyer_type: :holding,
            subscription_plan: :club,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 500,
            formation: "École de Commerce ESC, Formation continue M&A",
            experience: "Holding familiale, 4 entreprises au portefeuille (retail, services, distribution)",
            skills: "Acquisitions, intégration post-fusion, gestion de portefeuille, optimisation opérationnelle",
            investment_thesis: "Croissance externe pour diversifier notre portefeuille. Focus sur entreprises rentables dans commerce/services avec management en place.",
            target_sectors: ["Commerce", "Distribution", "Services aux entreprises", "Franchise"],
            target_locations: ["France entière"],
            target_revenue_min: 3_000_000,
            target_revenue_max: 25_000_000,
            target_employees_min: 20,
            target_employees_max: 200,
            target_transfer_types: ["Cession totale", "LBO"],
            target_customer_types: ["B2C", "B2B"],
            target_financial_health: :in_bonis,
            target_horizon: "Horizon 6-12 mois",
            investment_capacity: "5M€ - 15M€",
            funding_sources: "Fonds propres holding (60%), Dette senior (40%)",
            subscription_expires_at: 1.year.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :standard,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 75,
            formation: "Bac+5 École d'Ingénieurs, Executive MBA",
            experience: "12 ans dans l'industrie automobile en tant que directeur d'usine",
            skills: "Lean management, production, supply chain, amélioration continue",
            investment_thesis: "Reprise d'une PME industrielle pour mettre en pratique mon expertise opérationnelle et développer l'entreprise.",
            target_sectors: ["Industrie", "Mécanique", "Métallurgie", "Plasturgie"],
            target_locations: ["Hauts-de-France", "Grand Est", "Bourgogne-Franche-Comté"],
            target_revenue_min: 1_500_000,
            target_revenue_max: 8_000_000,
            target_employees_min: 10,
            target_employees_max: 60,
            target_transfer_types: ["Cession totale"],
            target_customer_types: ["B2B"],
            target_financial_health: :both,
            target_horizon: "Reprise d'ici 12 mois",
            investment_capacity: "800K€ - 2M€",
            funding_sources: "Apport personnel (30%), Crédit bancaire (70%)",
            subscription_expires_at: 4.months.from_now
          },
          {
            buyer_type: :fund,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 300,
            formation: "Équipe de 5 professionnels M&A avec plus de 50 ans d'expérience cumulée",
            experience: "Fonds d'investissement spécialisé PME françaises, 15 participations actuelles",
            skills: "LBO, croissance externe, restructuration, développement stratégique",
            investment_thesis: "Investissement dans PME leaders sur leur marché avec potentiel de consolidation. Accompagnement actif du management.",
            target_sectors: ["Services B2B", "Distribution", "E-commerce", "Technologies", "Santé"],
            target_locations: ["France entière", "Europe francophone"],
            target_revenue_min: 5_000_000,
            target_revenue_max: 50_000_000,
            target_employees_min: 30,
            target_employees_max: 300,
            target_transfer_types: ["LBO", "Cession partielle", "OBO"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Process continu d'investissement",
            investment_capacity: "10M€ - 40M€ par opération",
            funding_sources: "Fonds levés auprès d'institutionnels et family offices",
            subscription_expires_at: 1.year.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :starter,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: false,
            credits: 25,
            formation: "Master Commerce International, Formation reprise d'entreprise",
            experience: "8 ans en tant que directeur commercial dans le secteur des services",
            skills: "Développement commercial, négociation, gestion d'équipe commerciale",
            investment_thesis: "Première acquisition entrepreneuriale. Recherche entreprise saine avec fort potentiel de développement commercial.",
            target_sectors: ["Services aux entreprises", "Commerce", "Conseil"],
            target_locations: ["Île-de-France", "Pays de la Loire", "Bretagne"],
            target_revenue_min: 500_000,
            target_revenue_max: 3_000_000,
            target_employees_min: 5,
            target_employees_max: 30,
            target_transfer_types: ["Cession totale"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Recherche active (6-18 mois)",
            investment_capacity: "300K€ - 1M€",
            funding_sources: "Apport personnel (25%), Crédit bancaire (75%)",
            subscription_expires_at: 2.months.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 200,
            formation: "Diplôme expertise comptable, Master CCA",
            experience: "20 ans expérience cabinet comptable puis CFO PME (20M€ CA)",
            skills: "Finance, contrôle de gestion, restructuration financière, levée de fonds",
            investment_thesis: "Reprise d'entreprise avec problématiques financières à résoudre. Expertise en redressement et optimisation.",
            target_sectors: ["Tous secteurs"],
            target_locations: ["Occitanie", "Provence-Alpes-Côte d'Azur", "Auvergne-Rhône-Alpes"],
            target_revenue_min: 1_000_000,
            target_revenue_max: 10_000_000,
            target_employees_min: 8,
            target_employees_max: 80,
            target_transfer_types: ["Cession totale", "Redressement"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :both,
            target_horizon: "Horizon 3-9 mois",
            investment_capacity: "500K€ - 3M€",
            funding_sources: "Apport personnel (35%), Crédit vendeur (15%), Crédit bancaire (50%)",
            subscription_expires_at: 5.months.from_now
          },
          {
            buyer_type: :investor,
            subscription_plan: :standard,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 100,
            formation: "Business Angel certifié, Ancien entrepreneur (sortie réussie)",
            experience: "15 participations dans startups et PME innovantes",
            skills: "Investissement, conseil stratégique, mise en relation, développement business",
            investment_thesis: "Co-investissement avec repreneurs sérieux. Apport capital + expérience entrepreneuriale + réseau.",
            target_sectors: ["Technologies", "Digital", "E-commerce", "Services innovants"],
            target_locations: ["France métropolitaine"],
            target_revenue_min: 500_000,
            target_revenue_max: 5_000_000,
            target_employees_min: 5,
            target_employees_max: 50,
            target_transfer_types: ["Cession partielle", "Augmentation de capital"],
            target_customer_types: ["B2B", "B2C", "B2B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Co-investissement opportuniste",
            investment_capacity: "100K€ - 1M€ par participation",
            funding_sources: "Fonds personnels",
            subscription_expires_at: 3.months.from_now
          },
          {
            buyer_type: :holding,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 250,
            formation: "Groupe familial multi-générationnel",
            experience: "Holding patrimoniale gérant 8 PME dans secteurs variés depuis 30 ans",
            skills: "Gestion patrimoniale, restructuration, transmission d'entreprise, gouvernance",
            investment_thesis: "Acquisition d'entreprises familiales pérennes pour enrichir notre portefeuille. Vision long terme, respect des équipes.",
            target_sectors: ["Industrie", "Agroalimentaire", "Services", "Immobilier d'entreprise"],
            target_locations: ["Grand Est", "Bourgogne-Franche-Comté", "Hauts-de-France"],
            target_revenue_min: 2_000_000,
            target_revenue_max: 20_000_000,
            target_employees_min: 15,
            target_employees_max: 150,
            target_transfer_types: ["Cession totale", "Cession partielle"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Démarche permanente",
            investment_capacity: "3M€ - 12M€",
            funding_sources: "Trésorerie groupe (70%), Dette bancaire (30%)",
            subscription_expires_at: 8.months.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :standard,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: false,
            credits: 50,
            formation: "Master Management, Certification reprise entreprise CRA/CCI",
            experience: "10 ans manager dans grande distribution, souhaite devenir entrepreneur",
            skills: "Gestion de centre de profit, management d'équipes (50 pers.), logistique",
            investment_thesis: "Reprise d'entreprise de proximité dans commerce/distribution pour devenir chef d'entreprise.",
            target_sectors: ["Commerce de détail", "Grande distribution", "Franchise", "Restauration"],
            target_locations: ["Bretagne", "Pays de la Loire", "Normandie"],
            target_revenue_min: 800_000,
            target_revenue_max: 4_000_000,
            target_employees_min: 8,
            target_employees_max: 40,
            target_transfer_types: ["Cession totale"],
            target_customer_types: ["B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Projet à 12-18 mois",
            investment_capacity: "400K€ - 1.5M€",
            funding_sources: "Apport personnel (30%), Crédit bancaire (60%), Crédit vendeur (10%)",
            subscription_expires_at: 3.months.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 180,
            formation: "Ingénieur Centrale, Executive MBA",
            experience: "18 ans dans l'IT et le digital, dont 6 ans en tant que CTO startup (levée 10M€)",
            skills: "Transformation digitale, développement produit, management tech, innovation",
            investment_thesis: "Reprise PME traditionnelle pour accélérer transformation digitale et croissance. Apport compétences tech + vision stratégique.",
            target_sectors: ["Services", "Industrie", "Commerce", "Tous secteurs à digitaliser"],
            target_locations: ["Île-de-France", "Auvergne-Rhône-Alpes", "Occitanie"],
            target_revenue_min: 1_500_000,
            target_revenue_max: 12_000_000,
            target_employees_min: 10,
            target_employees_max: 100,
            target_transfer_types: ["Cession totale", "LBO"],
            target_customer_types: ["B2B", "B2C", "B2B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Recherche active 6 mois",
            investment_capacity: "1M€ - 4M€",
            funding_sources: "Apport personnel (40%), Investisseurs (20%), Crédit bancaire (40%)",
            subscription_expires_at: 7.months.from_now
          },
          {
            buyer_type: :fund,
            subscription_plan: :club,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 600,
            formation: "Fonds régional soutenu par BPI France et collectivités",
            experience: "25 investissements réalisés en 8 ans, tickets 500K€ à 5M€",
            skills: "Capital développement, accompagnement stratégique, mise en réseau",
            investment_thesis: "Soutien PME régionales en croissance. Capital patient, approche partenariale avec dirigeants.",
            target_sectors: ["Industrie", "Agroalimentaire", "Technologies", "Santé", "Services"],
            target_locations: ["Nouvelle-Aquitaine", "Occitanie"],
            target_revenue_min: 2_000_000,
            target_revenue_max: 30_000_000,
            target_employees_min: 15,
            target_employees_max: 200,
            target_transfer_types: ["Cession partielle", "Augmentation de capital", "OBO"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Investissements continus",
            investment_capacity: "500K€ - 5M€ par opération",
            funding_sources: "Fonds régional + co-investisseurs",
            subscription_expires_at: 1.year.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :starter,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: false,
            credits: 15,
            formation: "BTS Commerce, 15 ans d'expérience terrain",
            experience: "Responsable de magasin puis directeur régional (8 points de vente)",
            skills: "Commerce de proximité, relation client, gestion stocks, animation équipes",
            investment_thesis: "Devenir propriétaire de mon commerce. Recherche boutique ou franchise bien établie.",
            target_sectors: ["Commerce de détail", "Franchise", "Alimentation spécialisée"],
            target_locations: ["Sud de la France"],
            target_revenue_min: 300_000,
            target_revenue_max: 1_500_000,
            target_employees_min: 3,
            target_employees_max: 15,
            target_transfer_types: ["Cession totale"],
            target_customer_types: ["B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Projet à 6-12 mois",
            investment_capacity: "150K€ - 500K€",
            funding_sources: "Apport personnel (35%), Crédit bancaire (65%)",
            subscription_expires_at: 1.month.from_now
          },
          {
            buyer_type: :individual,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 175,
            formation: "Pharmacien diplômé, DU Gestion Officine",
            experience: "10 ans pharmacien salarié, recherche acquisition officine",
            skills: "Pharmacie, gestion officine, relation patients, conformité réglementaire",
            investment_thesis: "Acquisition officine pour développer projet entrepreneurial dans la santé de proximité.",
            target_sectors: ["Santé", "Pharmacie", "Parapharmacie"],
            target_locations: ["Île-de-France", "Provence-Alpes-Côte d'Azur", "Auvergne-Rhône-Alpes"],
            target_revenue_min: 800_000,
            target_revenue_max: 3_000_000,
            target_employees_min: 3,
            target_employees_max: 12,
            target_transfer_types: ["Cession totale"],
            target_customer_types: ["B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Acquisition sous 9 mois",
            investment_capacity: "400K€ - 1.2M€",
            funding_sources: "Apport personnel (40%), Crédit professionnel (60%)",
            subscription_expires_at: 6.months.from_now
          },
          {
            buyer_type: :holding,
            subscription_plan: :standard,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 120,
            formation: "Groupe industriel familial, 3ème génération",
            experience: "3 sites de production en France, 180 employés, spécialisation sous-traitance automobile",
            skills: "Industrie, production, qualité ISO, consolidation sectorielle",
            investment_thesis: "Croissance externe pour diversifier nos activités industrielles et gagner parts de marché.",
            target_sectors: ["Industrie", "Mécanique", "Plasturgie", "Sous-traitance"],
            target_locations: ["Hauts-de-France", "Grand Est", "Centre-Val de Loire"],
            target_revenue_min: 2_000_000,
            target_revenue_max: 15_000_000,
            target_employees_min: 15,
            target_employees_max: 100,
            target_transfer_types: ["Cession totale", "Adossement"],
            target_customer_types: ["B2B"],
            target_financial_health: :in_bonis,
            target_horizon: "Croissance externe continue",
            investment_capacity: "2M€ - 8M€",
            funding_sources: "Trésorerie groupe (50%), Dette bancaire (50%)",
            subscription_expires_at: 4.months.from_now
          },
          {
            buyer_type: :investor,
            subscription_plan: :premium,
            subscription_status: :active,
            profile_status: :published,
            verified_buyer: true,
            credits: 220,
            formation: "Club d'investisseurs (12 membres), entrepreneurs et cadres sup",
            experience: "8 investissements collectifs réalisés, accompagnement actif des repreneurs",
            skills: "Financement participatif, mentorat, réseau d'affaires étendu",
            investment_thesis: "Co-financement projets de reprise avec accompagnement personnalisé. Approche collaborative et bienveillante.",
            target_sectors: ["Services", "Commerce", "Digital", "Innovation"],
            target_locations: ["Île-de-France", "Principales métropoles"],
            target_revenue_min: 500_000,
            target_revenue_max: 8_000_000,
            target_employees_min: 5,
            target_employees_max: 60,
            target_transfer_types: ["Cession partielle", "Co-investissement"],
            target_customer_types: ["B2B", "B2C"],
            target_financial_health: :in_bonis,
            target_horizon: "Opportunités continues",
            investment_capacity: "200K€ - 2M€ collectif",
            funding_sources: "Membres du club",
            subscription_expires_at: 5.months.from_now
          }
        ]
        
        puts "\n💼 Creating buyer profiles..."
        
        # Assign profiles to buyer users
        buyer_users.each_with_index do |user, index|
          # Skip if user already has a profile, or use existing
          if user.buyer_profile.present?
            # Check if already published
            if user.buyer_profile.profile_status == 'published'
              puts "  ⚠️  #{user.full_name} already has a published profile"
              next
            else
              # Update existing profile to published
              profile_data = buyer_profiles_data[index % buyer_profiles_data.length]
              user.buyer_profile.update!(profile_data)
              user.buyer_profile.update_completeness!
              updated_count += 1
              puts "  ✓ Updated profile for #{user.full_name} (#{user.buyer_profile.buyer_type}, #{user.buyer_profile.subscription_plan})"
            end
          else
            # Create new profile
            profile_data = buyer_profiles_data[index % buyer_profiles_data.length]
            buyer_profile = user.create_buyer_profile!(profile_data)
            buyer_profile.update_completeness!
            created_count += 1
            puts "  ✓ Created profile for #{user.full_name} (#{buyer_profile.buyer_type}, #{buyer_profile.subscription_plan}, completeness: #{buyer_profile.completeness_score}%)"
          end
        end
        
        # Summary
        puts "\n📊 Buyer Profile Seeding Summary:"
        puts "  ✨ Created: #{created_count} new profiles"
        puts "  🔄 Updated: #{updated_count} existing profiles"
        puts "  📈 Total published buyer profiles: #{BuyerProfile.published_profiles.count}"
        puts "  ✅ Verified buyers: #{BuyerProfile.verified.count}"
        puts "  🎯 Target sectors coverage: #{BuyerProfile.published_profiles.count} profiles"
        
        puts "\n📋 Subscription breakdown:"
        BuyerProfile.subscription_plans.each do |plan, _|
          count = BuyerProfile.published_profiles.where(subscription_plan: plan).count
          puts "  #{plan.capitalize}: #{count} profiles"
        end
        
        puts "\n👥 Buyer type breakdown:"
        BuyerProfile.buyer_types.each do |type, _|
          count = BuyerProfile.published_profiles.where(buyer_type: type).count
          puts "  #{type.capitalize}: #{count} profiles"
        end
        
        puts "\n✅ Buyer profile seeding completed successfully!"
        puts "💡 You can now view the buyer directory at: http://localhost:3000/seller/buyers"
        
      end
      
    rescue => e
      puts "\n❌ Error during buyer profile seeding: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      raise e
    end
  end
end
