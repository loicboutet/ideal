class Seller::DashboardController < SellerController
  def index
    # Seller dashboard overview
    @my_listings = current_seller_listings.includes(:listing_views, :favorites)
    @active_listings_count = @my_listings.active.count
    @pending_listings_count = @my_listings.pending_validation.count
    @draft_listings_count = @my_listings.draft.count
    
    # Performance metrics
    @total_views = calculate_total_views
    @total_favorites = calculate_total_favorites
    @interested_buyers_count = calculate_interested_buyers
    
    # Recent activity on my listings
    @recent_views = ListingView.joins(:listing)
                               .where(listing: @my_listings)
                               .recent
                               .limit(10)
                               .includes(:user, :listing)
    
    @recent_favorites = Favorite.joins(:listing)
                                .where(listing: @my_listings)
                                .recent
                                .limit(5)
                                .includes(:user, :listing)
    
    # Buyers who showed interest
    @interested_buyers = User.buyers
                             .joins(:deals)
                             .where(deals: { listing: @my_listings })
                             .distinct
                             .limit(10)
    
    # Credits and subscription status
    @current_credits = current_seller_profile&.credits || 0
    @subscription = current_user.subscriptions.active.first
    
    # Quick actions suggestions
    @suggested_actions = calculate_suggested_actions
  end

  private

  def calculate_total_views
    ListingView.joins(:listing)
               .where(listing: current_seller_listings)
               .count
  end

  def calculate_total_favorites
    Favorite.joins(:listing)
            .where(listing: current_seller_listings)
            .count
  end

  def calculate_interested_buyers
    Deal.joins(:listing)
        .where(listing: current_seller_listings)
        .select(:buyer_id)
        .distinct
        .count
  end

  def calculate_suggested_actions
    actions = []
    
    # Suggest completing profile if not done
    unless current_seller_profile&.completed?
      actions << {
        type: 'complete_profile',
        title: 'Complétez votre profil',
        description: 'Un profil complet attire plus d\'acheteurs',
        url: seller_profile_path
      }
    end
    
    # Suggest adding listings if none exist
    if current_seller_listings.count == 0
      actions << {
        type: 'create_listing',
        title: 'Créez votre première annonce',
        description: 'Commencez par publier une entreprise à céder',
        url: new_seller_listing_path
      }
    end
    
    # Suggest uploading documents for incomplete listings
    incomplete_listings = current_seller_listings.where.not(completeness_score: 100)
    if incomplete_listings.any?
      actions << {
        type: 'add_documents',
        title: 'Ajoutez des documents',
        description: "#{incomplete_listings.count} annonce(s) peuvent être enrichies",
        url: seller_listings_path
      }
    end
    
    # Suggest exploring buyer directory if has no views
    no_view_listings = current_seller_listings.joins("LEFT JOIN listing_views ON listing_views.listing_id = listings.id")
                                              .where(listing_views: { id: nil })
    if no_view_listings.any?
      actions << {
        type: 'browse_buyers',
        title: 'Découvrez des repreneurs',
        description: 'Trouvez des acheteurs potentiels pour vos annonces',
        url: seller_buyers_path
      }
    end
    
    actions
  end
end
