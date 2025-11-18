class Buyer::DashboardController < BuyerController
  def index
    # Buyer CRM dashboard overview
    @pipeline_stats = calculate_pipeline_stats
    @active_deals_count = current_buyer_deals.active.count
    @favorites_count = current_buyer_favorites.count
    @credits_balance = current_buyer_profile&.credits || 0
    
    # Recent listings matching buyer's profile
    @matching_listings = find_matching_listings.limit(5)
    @new_listings_count = Listing.active.where('created_at > ?', 7.days.ago).count
    
    # CRM pipeline overview (10 stages)
    @pipeline_stages = {
      'favorites' => current_buyer_deals.favorites.count,
      'to_contact' => current_buyer_deals.to_contact.count,
      'info_exchange' => current_buyer_deals.info_exchange.count,
      'analysis' => current_buyer_deals.analysis.count,
      'project_alignment' => current_buyer_deals.project_alignment.count,
      'negotiation' => current_buyer_deals.negotiation.count,
      'loi' => current_buyer_deals.loi.count,
      'audits' => current_buyer_deals.audits.count,
      'financing' => current_buyer_deals.financing.count,
      'deal_signed' => current_buyer_deals.deal_signed.count
    }
    
    # Expiring timers - urgent actions needed
    @expiring_deals = current_buyer_deals.with_expiring_timers.limit(5)
    
    # Recent activity
    @recent_messages = Message.where(recipient: current_user).recent.limit(5)
    @recent_activities = Activity.where(user: current_user).recent.limit(10)
    
    # Subscription status
    @subscription = current_user.subscriptions.active.first
    @subscription_expires_soon = @subscription&.expires_at&.< 30.days.from_now
    
    # Quick actions
    @suggested_actions = calculate_suggested_actions
  end

  private

  def calculate_pipeline_stats
    deals = current_buyer_deals
    total_deals = deals.count
    
    return { conversion_rate: 0, average_time: 0, total_deals: 0 } if total_deals == 0
    
    signed_deals = deals.deal_signed.count
    conversion_rate = (signed_deals.to_f / total_deals * 100).round(1)
    
    # Average time to close (mock calculation)
    average_time = deals.deal_signed.average('EXTRACT(EPOCH FROM (updated_at - created_at))')&.to_i || 0
    average_days = (average_time / 86400).round(1)
    
    {
      conversion_rate: conversion_rate,
      average_time: average_days,
      total_deals: total_deals,
      signed_deals: signed_deals
    }
  end

  def find_matching_listings
    return Listing.none unless current_buyer_profile
    
    profile = current_buyer_profile
    
    # Match based on buyer's investment criteria
    listings = Listing.active
    
    # Filter by target sectors if specified
    if profile.target_sectors.present?
      listings = listings.where(industry_sector: profile.target_sectors)
    end
    
    # Filter by revenue range if specified
    if profile.target_revenue_min.present? && profile.target_revenue_max.present?
      listings = listings.where(
        'annual_revenue BETWEEN ? AND ?', 
        profile.target_revenue_min, 
        profile.target_revenue_max
      )
    end
    
    # Filter by geography if specified
    if profile.target_locations.present?
      listings = listings.where(department: profile.target_locations)
    end
    
    # Filter by employee count if specified
    if profile.target_employees_min.present?
      listings = listings.where('employee_count >= ?', profile.target_employees_min)
    end
    
    listings.includes(:seller_profile, :listing_documents)
  end

  def calculate_suggested_actions
    actions = []
    
    # Suggest completing profile if not done
    unless current_buyer_profile&.completed?
      actions << {
        type: 'complete_profile',
        title: 'Complétez votre profil',
        description: 'Un profil complet améliore vos recommandations',
        url: buyer_profile_path,
        priority: 'high'
      }
    end
    
    # Suggest browsing listings if no favorites
    if current_buyer_favorites.count == 0
      actions << {
        type: 'browse_listings',
        title: 'Découvrez des entreprises',
        description: 'Commencez par explorer les annonces disponibles',
        url: buyer_listings_path,
        priority: 'medium'
      }
    end
    
    # Suggest upgrading subscription if using free plan
    unless buyer_has_access?
      actions << {
        type: 'upgrade_subscription',
        title: 'Activez votre abonnement',
        description: 'Accédez à toutes les fonctionnalités premium',
        url: buyer_subscription_path,
        priority: 'high'
      }
    end
    
    # Alert about expiring deals
    if @expiring_deals.any?
      actions << {
        type: 'expiring_deals',
        title: 'Actions urgentes requises',
        description: "#{@expiring_deals.count} dossier(s) expire(nt) bientôt",
        url: buyer_pipeline_path,
        priority: 'urgent'
      }
    end
    
    # Suggest contacting sellers for long-standing favorites
    old_favorites = current_buyer_favorites.where('created_at < ?', 7.days.ago).limit(3)
    if old_favorites.any?
      actions << {
        type: 'contact_sellers',
        title: 'Contactez les vendeurs',
        description: "#{old_favorites.count} favorite(s) en attente de contact",
        url: buyer_favorites_path,
        priority: 'medium'
      }
    end
    
    actions.sort_by { |action| action[:priority] == 'urgent' ? 0 : action[:priority] == 'high' ? 1 : 2 }
  end
end
