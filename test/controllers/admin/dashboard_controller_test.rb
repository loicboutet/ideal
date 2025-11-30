require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin)
    @seller_user = users(:seller)
    @buyer_user = users(:buyer)
    @partner_user = users(:partner)
  end

  # =========================================================================
  # Authentication & Authorization Tests
  # =========================================================================

  test "should get index for authenticated admin" do
    sign_in @admin_user
    get admin_root_path
    assert_response :success
  end

  test "should redirect unauthenticated users to login" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect sellers to root path" do
    sign_in @seller_user
    get admin_root_path
    assert_redirected_to root_path
    assert_equal 'Access denied. Admin privileges required.', flash[:alert]
  end

  test "should redirect buyers to root path" do
    sign_in @buyer_user
    get admin_root_path
    assert_redirected_to root_path
  end

  test "should redirect partners to root path" do
    sign_in @partner_user
    get admin_root_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Operations Page - Access Tests
  # =========================================================================

  test "should get operations for authenticated admin" do
    sign_in @admin_user
    get admin_operations_path
    assert_response :success
  end

  test "should redirect non-admins from operations" do
    sign_in @seller_user
    get admin_operations_path
    assert_redirected_to root_path
  end

  test "should redirect unauthenticated from operations" do
    get admin_operations_path
    assert_redirected_to new_user_session_path
  end

  # =========================================================================
  # Operations - Zero Views Count Tests
  # =========================================================================

  test "should calculate zero views count accurately" do
    sign_in @admin_user
    get admin_operations_path
    
    zero_views_count = assigns(:zero_views_count)
    assert_not_nil zero_views_count
    
    # Expected: listings that are approved, published, and have 0 or null views
    expected = Listing.where(validation_status: :approved, status: :published)
                      .where('views_count = 0 OR views_count IS NULL')
                      .count
    
    assert_equal expected, zero_views_count
  end

  test "should include listing_zero_views in count" do
    sign_in @admin_user
    get admin_operations_path
    
    zero_views_count = assigns(:zero_views_count)
    
    # From fixtures: listing_zero_views, listing_zero_views_two both have 0 views and are approved/published
    assert zero_views_count >= 2, "Expected at least 2 listings with zero views"
  end

  # =========================================================================
  # Operations - Pending Validations Count Tests
  # =========================================================================

  test "should calculate pending validations count" do
    sign_in @admin_user
    get admin_operations_path
    
    pending_count = assigns(:pending_validations_count)
    assert_not_nil pending_count
    
    expected = Listing.where(validation_status: :pending).count
    assert_equal expected, pending_count
  end

  test "should include pending listings in count" do
    sign_in @admin_user
    get admin_operations_path
    
    pending_count = assigns(:pending_validations_count)
    
    # From fixtures: listing_pending, listing_pending_two are pending
    assert pending_count >= 2, "Expected at least 2 pending listings"
  end

  # =========================================================================
  # Operations - Expired Timers Count Tests
  # =========================================================================

  test "should calculate expired timers count" do
    sign_in @admin_user
    get admin_operations_path
    
    expired_count = assigns(:expired_timers_count)
    assert_not_nil expired_count
    
    expected = Deal.where.not(reserved_until: nil)
                   .where('reserved_until < ?', Time.current)
                   .count
    
    assert_equal expected, expired_count
  end

  test "should include expired deals in count" do
    sign_in @admin_user
    get admin_operations_path
    
    expired_count = assigns(:expired_timers_count)
    
    # From fixtures: deal_expired (5 days ago), deal_expired_two (2 days ago)
    assert expired_count >= 2, "Expected at least 2 expired timer deals"
  end

  # =========================================================================
  # Operations - CRM Status Distribution Tests
  # =========================================================================

  test "should calculate deals by status distribution" do
    sign_in @admin_user
    get admin_operations_path
    
    deals_by_status = assigns(:deals_by_status)
    assert_not_nil deals_by_status
    assert_kind_of Hash, deals_by_status
    
    # Verify counts match actual data
    expected = Deal.group(:status).count
    assert_equal expected, deals_by_status
  end

  test "should include all deal statuses in distribution" do
    sign_in @admin_user
    get admin_operations_path
    
    deals_by_status = assigns(:deals_by_status)
    
    # From fixtures: we have deals in info_exchange, negotiation, analysis, to_contact, loi, favorited, signed
    # The hash keys should be present for statuses that have deals
    total_deals = deals_by_status.values.sum
    expected_total = Deal.count
    assert_equal expected_total, total_deals
  end

  # =========================================================================
  # Operations - Listings Per Buyer Ratio Tests
  # =========================================================================

  test "should calculate listings per buyer ratio" do
    sign_in @admin_user
    get admin_operations_path
    
    ratio = assigns(:listings_per_buyer_ratio)
    assert_not_nil ratio
    
    active_listings = Listing.where(validation_status: :approved, status: :published).count
    paying_buyers = BuyerProfile.where(subscription_status: :active).count
    
    expected = paying_buyers > 0 ? (active_listings.to_f / paying_buyers).round(1) : 0
    assert_equal expected, ratio
  end

  test "should handle zero paying buyers in ratio" do
    # Deactivate all buyer subscriptions
    BuyerProfile.update_all(subscription_status: :inactive)
    
    sign_in @admin_user
    get admin_operations_path
    
    ratio = assigns(:listings_per_buyer_ratio)
    assert_equal 0, ratio
  end

  # =========================================================================
  # Operations - Other KPIs Tests
  # =========================================================================

  test "should calculate active listings count" do
    sign_in @admin_user
    get admin_operations_path
    
    active_count = assigns(:active_listings_count)
    assert_not_nil active_count
    
    expected = Listing.where(validation_status: :approved, status: :published).count
    assert_equal expected, active_count
  end

  test "should calculate paying buyers count" do
    sign_in @admin_user
    get admin_operations_path
    
    paying_count = assigns(:paying_buyers_count)
    assert_not_nil paying_count
    
    expected = BuyerProfile.where(subscription_status: :active).count
    assert_equal expected, paying_count
  end

  test "should calculate active reservations" do
    sign_in @admin_user
    get admin_operations_path
    
    active_reservations = assigns(:active_reservations)
    assert_not_nil active_reservations
    
    expected = Deal.where(reserved: true).where.not(reserved_until: nil).count
    assert_equal expected, active_reservations
  end

  # =========================================================================
  # Drilldown - Zero Views Page Tests
  # =========================================================================

  test "should get zero_views drilldown page" do
    sign_in @admin_user
    get admin_dashboard_zero_views_path
    assert_response :success
  end

  test "should list listings with zero views" do
    sign_in @admin_user
    get admin_dashboard_zero_views_path
    
    listings = assigns(:listings)
    assert_not_nil listings
    
    # All returned listings should have 0 views and be approved/published
    listings.each do |listing|
      assert listing.views_count == 0 || listing.views_count.nil?,
             "Listing #{listing.id} should have 0 views but has #{listing.views_count}"
      assert_equal 'approved', listing.validation_status
      assert_equal 'published', listing.status
    end
  end

  test "should paginate zero views listings" do
    sign_in @admin_user
    get admin_dashboard_zero_views_path, params: { page: 1 }
    
    listings = assigns(:listings)
    # Kaminari pagination should be applied (max 20 per page)
    assert listings.count <= 20
  end

  test "should redirect non-admins from zero_views" do
    sign_in @seller_user
    get admin_dashboard_zero_views_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Drilldown - Expired Timers Page Tests
  # =========================================================================

  test "should get expired_timers drilldown page" do
    sign_in @admin_user
    get admin_dashboard_expired_timers_path
    assert_response :success
  end

  test "should list deals with expired timers" do
    sign_in @admin_user
    get admin_dashboard_expired_timers_path
    
    deals = assigns(:deals)
    assert_not_nil deals
    
    # All returned deals should have expired timers
    deals.each do |deal|
      assert deal.reserved_until < Time.current,
             "Deal #{deal.id} timer not expired: #{deal.reserved_until}"
    end
  end

  test "should paginate expired timers" do
    sign_in @admin_user
    get admin_dashboard_expired_timers_path, params: { page: 1 }
    
    deals = assigns(:deals)
    assert deals.count <= 20
  end

  test "should redirect non-admins from expired_timers" do
    sign_in @buyer_user
    get admin_dashboard_expired_timers_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Empty States Tests
  # =========================================================================

  test "should handle no listings with zero views" do
    # Give all approved/published listings some views
    Listing.where(validation_status: :approved, status: :published).update_all(views_count: 10)
    
    sign_in @admin_user
    get admin_dashboard_zero_views_path
    
    assert_response :success
    listings = assigns(:listings)
    assert_empty listings
  end

  test "should handle no expired timers" do
    # Update all deals to have future timers
    Deal.where.not(reserved_until: nil).update_all(reserved_until: 30.days.from_now)
    
    sign_in @admin_user
    get admin_dashboard_expired_timers_path
    
    assert_response :success
    deals = assigns(:deals)
    assert_empty deals
  end

  test "should handle no pending validations" do
    Listing.where(validation_status: :pending).update_all(validation_status: :approved)
    
    sign_in @admin_user
    get admin_operations_path
    
    pending_count = assigns(:pending_validations_count)
    assert_equal 0, pending_count
  end

  # =========================================================================
  # User Distribution Tests
  # =========================================================================

  test "should build user distribution" do
    sign_in @admin_user
    get admin_operations_path
    
    user_distribution = assigns(:user_distribution)
    assert_not_nil user_distribution
    assert_kind_of Array, user_distribution
    
    # Should have 3 categories: Cédants, Repreneurs, Partenaires
    labels = user_distribution.map { |d| d[:label] }
    assert_includes labels, 'Cédants'
    assert_includes labels, 'Repreneurs'
    assert_includes labels, 'Partenaires'
  end
end
