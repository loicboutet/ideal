class Partner::DashboardController < PartnerController
  def index
    # Partner dashboard overview
    @profile_completeness = calculate_profile_completeness
    @directory_visible = directory_visible?
    @subscription_active = partner_has_directory_access?
    
    # Contact and lead metrics
    @total_contacts = partner_contacts.count
    @recent_contacts = partner_contacts.recent.limit(10)
    @monthly_contacts = partner_contacts.where('created_at > ?', 1.month.ago).count
    
    # Profile performance
    @profile_views = calculate_profile_views
    @profile_views_this_month = calculate_profile_views(1.month.ago)
    
    # Directory ranking and visibility
    @directory_ranking = calculate_directory_ranking
    @coverage_areas = current_partner_profile&.coverage_areas || []
    @specializations = current_partner_profile&.specializations || []
    
    # Subscription status
    @subscription = current_user.subscriptions.directory.active.first
    @subscription_expires_at = @subscription&.expires_at
    @subscription_expires_soon = @subscription_expires_at&.< 30.days.from_now
    
    # Revenue tracking (leads converted to business)
    @revenue_opportunities = calculate_revenue_opportunities
    
    # Quick actions and recommendations
    @suggested_actions = calculate_suggested_actions
  end

  def analytics
    # Detailed analytics for partner performance
    @time_period = params[:period] || '3.months'
    start_date = case @time_period
                when '1.month' then 1.month.ago
                when '3.months' then 3.months.ago
                when '6.months' then 6.months.ago
                when '1.year' then 1.year.ago
                else 3.months.ago
                end
    
    # Contact trends
    @contacts_trend = calculate_contacts_trend(start_date)
    @contacts_by_source = calculate_contacts_by_source(start_date)
    
    # Profile performance
    @views_trend = calculate_views_trend(start_date)
    @conversion_rate = calculate_contact_conversion_rate(start_date)
    
    # Geographic distribution of contacts
    @contacts_by_location = calculate_contacts_by_location(start_date)
    
    # Service type performance
    @contacts_by_service = calculate_contacts_by_service(start_date)
    
    # Competitive analysis (position in directory)
    @competitor_analysis = calculate_competitor_analysis
  end

  private

  def calculate_profile_completeness
    profile = current_partner_profile
    return 0 unless profile
    
    total_fields = 10
    completed_fields = 0
    
    completed_fields += 1 if profile.company_name.present?
    completed_fields += 1 if profile.description.present?
    completed_fields += 1 if profile.services.present?
    completed_fields += 1 if profile.coverage_areas.present?
    completed_fields += 1 if profile.website.present?
    completed_fields += 1 if profile.phone.present?
    completed_fields += 1 if profile.specializations.present?
    completed_fields += 1 if profile.experience_years.present?
    completed_fields += 1 if profile.team_size.present?
    completed_fields += 1 if profile.calendar_link.present?
    
    (completed_fields.to_f / total_fields * 100).round
  end

  def calculate_profile_views
    # Mock calculation - would integrate with actual analytics
    base_views = partner_contacts.count * 3 # Estimate 3 views per contact
    additional_views = current_partner_profile&.created_at&.< 6.months.ago ? 150 : 50
    base_views + additional_views
  end

  def calculate_directory_ranking
    # Mock ranking calculation based on profile completeness, contacts, and activity
    completeness_score = calculate_profile_completeness
    activity_score = [partner_contacts.count * 2, 100].min
    recency_score = current_partner_profile&.updated_at&.> 1.month.ago ? 20 : 0
    
    total_score = completeness_score + activity_score + recency_score
    ranking = case total_score
             when 180..300 then 'Excellent'
             when 140..179 then 'Très bon'
             when 100..139 then 'Bon'
             when 60..99 then 'Moyen'
             else 'À améliorer'
             end
    
    { score: total_score, ranking: ranking, max_score: 220 }
  end

  def calculate_revenue_opportunities
    # Estimate revenue opportunities based on contacts and business size
    recent_contacts = partner_contacts.where('created_at > ?', 3.months.ago)
    
    # Mock calculation based on contact types and typical deal sizes
    opportunities = recent_contacts.map do |contact|
      estimated_value = case contact.business_size
                       when 'small' then rand(5_000..15_000)
                       when 'medium' then rand(15_000..50_000)
                       when 'large' then rand(50_000..200_000)
                       else rand(5_000..25_000)
                       end
      
      {
        contact: contact,
        estimated_value: estimated_value,
        probability: rand(20..80)
      }
    end
    
    {
      total_opportunities: opportunities.count,
      total_estimated_value: opportunities.sum { |opp| opp[:estimated_value] },
      weighted_value: opportunities.sum { |opp| opp[:estimated_value] * opp[:probability] / 100 }
    }
  end

  def calculate_suggested_actions
    actions = []
    
    # Suggest completing profile if not done
    completeness = calculate_profile_completeness
    if completeness < 80
      actions << {
        type: 'complete_profile',
        title: 'Complétez votre profil',
        description: "Votre profil est complété à #{completeness}%",
        url: partner_profile_path,
        priority: 'high'
      }
    end
    
    # Remind about subscription renewal
    if @subscription_expires_soon
      days_left = (@subscription_expires_at - Date.current).to_i
      actions << {
        type: 'renew_subscription',
        title: 'Renouvelez votre abonnement',
        description: "Votre abonnement expire dans #{days_left} jour(s)",
        url: partner_subscription_path,
        priority: 'urgent'
      }
    end
    
    # Suggest updating profile for better visibility
    if current_partner_profile&.updated_at&.< 2.months.ago
      actions << {
        type: 'update_profile',
        title: 'Mettez à jour votre profil',
        description: 'Un profil récent améliore votre visibilité',
        url: edit_partner_profile_path,
        priority: 'medium'
      }
    end
    
    # Suggest responding to contacts if there are pending ones
    pending_contacts = partner_contacts.where(status: 'pending').count
    if pending_contacts > 0
      actions << {
        type: 'respond_contacts',
        title: 'Répondez aux contacts',
        description: "#{pending_contacts} contact(s) en attente de réponse",
        url: partner_contacts_path,
        priority: 'high'
      }
    end
    
    actions.sort_by { |action| action[:priority] == 'urgent' ? 0 : action[:priority] == 'high' ? 1 : 2 }
  end

  def calculate_contacts_trend(start_date)
    # Mock data for contacts trend
    contacts_by_month = partner_contacts.where('created_at >= ?', start_date)
                                       .group_by_month(:created_at)
                                       .count
    
    (start_date.to_date..Date.current).map do |date|
      month_key = date.beginning_of_month
      {
        date: month_key,
        count: contacts_by_month[month_key] || 0
      }
    end
  end

  def calculate_contacts_by_source(start_date)
    # Mock data - sources of contacts
    {
      'Annuaire partenaires' => partner_contacts.where('created_at >= ?', start_date).count,
      'Recherche Google' => rand(5..15),
      'Recommandation' => rand(2..8),
      'Site web' => rand(1..5)
    }
  end

  def calculate_views_trend(start_date)
    # Mock data for profile views trend
    base_views = 50
    (start_date.to_date..Date.current).map do |date|
      {
        date: date,
        count: base_views + rand(-10..10)
      }
    end
  end

  def calculate_contact_conversion_rate(start_date)
    contacts = partner_contacts.where('created_at >= ?', start_date).count
    views = calculate_profile_views
    
    return 0 if views == 0
    (contacts.to_f / views * 100).round(2)
  end

  def calculate_contacts_by_location(start_date)
    # Mock geographic distribution
    {
      'Île-de-France' => rand(10..25),
      'Auvergne-Rhône-Alpes' => rand(5..15),
      'Nouvelle-Aquitaine' => rand(3..12),
      'Occitanie' => rand(2..10),
      'Autres' => rand(5..20)
    }
  end

  def calculate_contacts_by_service(start_date)
    # Mock service performance
    {
      'Audit & Conseil' => rand(8..20),
      'Accompagnement juridique' => rand(5..15),
      'Financement' => rand(3..12),
      'Valorisation' => rand(2..8),
      'Due diligence' => rand(1..6)
    }
  end

  def calculate_competitor_analysis
    # Mock competitive positioning
    total_partners = PartnerProfile.approved.count
    my_ranking = rand(1..total_partners)
    
    {
      total_partners: total_partners,
      my_ranking: my_ranking,
      percentile: ((total_partners - my_ranking).to_f / total_partners * 100).round,
      category_ranking: rand(1..20),
      category_total: rand(20..50)
    }
  end
end
