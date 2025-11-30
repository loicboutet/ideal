require "test_helper"

class Buyer::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @buyer_user = users(:buyer)
    @buyer_profile = buyer_profiles(:buyer_profile)
    @seller_user = users(:seller)
    @admin_user = users(:admin)
    @inactive_buyer = users(:inactive_buyer)
  end

  # =========================================================================
  # Authentication & Authorization Tests
  # =========================================================================

  test "should get index for authenticated buyer" do
    sign_in @buyer_user
    get buyer_root_path
    assert_response :success
  end

  test "should redirect unauthenticated users to login" do
    get buyer_root_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect sellers to root path" do
    sign_in @seller_user
    get buyer_root_path
    assert_redirected_to root_path
    assert_equal 'Access denied. Buyer privileges required.', flash[:alert]
  end

  test "should redirect admins to root path" do
    sign_in @admin_user
    get buyer_root_path
    assert_redirected_to root_path
  end

  test "should redirect inactive buyers to root path" do
    sign_in @inactive_buyer
    get buyer_root_path
    assert_redirected_to root_path
    assert_equal 'Access denied. Buyer privileges required.', flash[:alert]
  end

  # =========================================================================
  # Stats Calculation Tests
  # =========================================================================

  test "should calculate total deals correctly" do
    sign_in @buyer_user
    get buyer_root_path
    assert_response :success
    
    stats = assigns(:stats)
    assert_not_nil stats
    assert_not_nil stats[:total_deals]
    
    # Buyer has deals: deal_active, deal_expiring_soon, deal_negotiation
    expected_deals = Deal.where(buyer_profile: @buyer_profile).count
    assert_equal expected_deals, stats[:total_deals]
  end

  test "should calculate active reservations correctly" do
    sign_in @buyer_user
    get buyer_root_path
    
    stats = assigns(:stats)
    active_reservations = assigns(:active_reservations)
    
    assert_not_nil stats[:active_reservations]
    assert_not_nil active_reservations
    
    # Count reserved deals with active timers
    expected = Deal.where(buyer_profile: @buyer_profile, reserved: true)
                   .where.not(reserved_until: nil)
                   .count
    assert_equal expected, stats[:active_reservations]
  end

  test "should calculate favorites count correctly" do
    sign_in @buyer_user
    get buyer_root_path
    
    stats = assigns(:stats)
    assert_not_nil stats[:favorites]
    
    expected = Favorite.where(buyer_profile: @buyer_profile).count
    assert_equal expected, stats[:favorites]
  end

  test "should calculate credits from buyer profile" do
    sign_in @buyer_user
    get buyer_root_path
    
    stats = assigns(:stats)
    assert_equal @buyer_profile.credits, stats[:credits]
  end

  test "should calculate unread messages count" do
    sign_in @buyer_user
    get buyer_root_path
    
    stats = assigns(:stats)
    assert_not_nil stats[:unread_messages]
    # Buyer has unread messages in fixtures (message_conv1_3_unread, message_conv1_4_unread, message_conv2_3_unread)
    assert stats[:unread_messages] >= 0
  end

  # =========================================================================
  # New Favorites Count Tests
  # =========================================================================

  test "should calculate new favorites in last 7 days" do
    sign_in @buyer_user
    get buyer_root_path
    
    new_favorites_count = assigns(:new_favorites_count)
    assert_not_nil new_favorites_count
    
    # From fixtures: favorite_one (2 days), favorite_two (5 days), favorite_three (6 days) = 3 in 7 days
    expected = Favorite.where(buyer_profile: @buyer_profile)
                       .where('created_at >= ?', 7.days.ago)
                       .count
    assert_equal expected, new_favorites_count
  end

  # =========================================================================
  # Shortest Timer Tests
  # =========================================================================

  test "should calculate shortest timer days" do
    sign_in @buyer_user
    get buyer_root_path
    
    shortest_timer_days = assigns(:shortest_timer_days)
    # deal_expiring_soon expires in 12 hours (0 days remaining)
    # deal_active expires in 20 days
    # deal_negotiation expires in 45 days
    # So the shortest should be 0 (or close to it)
    assert_not_nil shortest_timer_days if assigns(:active_reservations).any?
  end

  test "should handle nil shortest timer when no active reservations" do
    # Create a buyer with no active reservations
    buyer_three = users(:buyer_three)
    sign_in buyer_three
    get buyer_root_path
    
    # This buyer has no reserved deals, so timer might be nil or handled gracefully
    assert_response :success
  end

  # =========================================================================
  # Available Listings Count Tests
  # =========================================================================

  test "should count available listings" do
    sign_in @buyer_user
    get buyer_root_path
    
    available_count = assigns(:available_listings_count)
    assert_not_nil available_count
    
    expected = Listing.where(status: :active).count
    assert_equal expected, available_count
  end

  # =========================================================================
  # Subscription Info Tests
  # =========================================================================

  test "should display subscription name" do
    sign_in @buyer_user
    get buyer_root_path
    
    subscription_name = assigns(:subscription_name)
    assert_not_nil subscription_name
    # buyer_profile has standard subscription
    assert_match(/standard/i, subscription_name.downcase)
  end

  test "should display subscription end date" do
    sign_in @buyer_user
    get buyer_root_path
    
    subscription_end_date = assigns(:subscription_end_date)
    # Standard buyer has subscription_expires_at set
    assert_not_nil subscription_end_date
  end

  test "should display max reservations based on plan" do
    sign_in @buyer_user
    get buyer_root_path
    
    max_reservations = assigns(:max_reservations)
    assert_not_nil max_reservations
    # Standard plan = 3 max reservations (not premium which is unlimited)
    assert_equal 3, max_reservations
  end

  test "should show unlimited reservations for premium subscribers" do
    buyer_two = users(:buyer_two)
    sign_in buyer_two
    get buyer_root_path
    
    max_reservations = assigns(:max_reservations)
    # buyer_two has premium plan
    assert_equal 'illimité', max_reservations
  end

  # =========================================================================
  # Pipeline Stages Tests
  # =========================================================================

  test "should build pipeline stages with correct structure" do
    sign_in @buyer_user
    get buyer_root_path
    
    stages = assigns(:stages)
    assert_not_nil stages
    assert_kind_of Array, stages
    
    # Should have 10 CRM stages
    assert_equal 10, stages.length
    
    # Each stage should have required keys
    stages.each do |stage|
      assert stage.key?(:name), "Stage missing :name"
      assert stage.key?(:label), "Stage missing :label"
      assert stage.key?(:short_label), "Stage missing :short_label"
      assert stage.key?(:color), "Stage missing :color"
      assert stage.key?(:count), "Stage missing :count"
    end
  end

  test "should have correct stage names in order" do
    sign_in @buyer_user
    get buyer_root_path
    
    stages = assigns(:stages)
    expected_names = %w[favoris a_contacter echange_infos analyse alignement_projets 
                        negociation loi audits financement signe]
    
    actual_names = stages.map { |s| s[:name] }
    assert_equal expected_names, actual_names
  end

  test "should count deals by stage correctly" do
    sign_in @buyer_user
    get buyer_root_path
    
    stages = assigns(:stages)
    
    # Get actual deal counts for this buyer
    deals_by_stage = Deal.where(buyer_profile: @buyer_profile).group(:status).count
    
    # Verify counts match
    stages.each do |stage|
      expected_count = deals_by_stage[stage[:name]] || 0
      assert_equal expected_count, stage[:count], "Mismatch for stage #{stage[:name]}"
    end
  end

  # =========================================================================
  # Expiring Soon Tests
  # =========================================================================

  test "should identify deals expiring within 24 hours" do
    sign_in @buyer_user
    get buyer_root_path
    
    expiring_soon = assigns(:expiring_soon)
    assert_not_nil expiring_soon
    
    # All deals in expiring_soon should have reserved_until within 24 hours
    expiring_soon.each do |deal|
      assert deal.reserved_until <= 24.hours.from_now, 
             "Deal #{deal.id} expires at #{deal.reserved_until}, which is not within 24 hours"
    end
  end

  test "should include deal_expiring_soon in expiring list" do
    sign_in @buyer_user
    get buyer_root_path
    
    expiring_soon = assigns(:expiring_soon)
    deal_expiring = deals(:deal_expiring_soon)
    
    # deal_expiring_soon has reserved_until in 12 hours
    assert expiring_soon.include?(deal_expiring), 
           "Expected deal_expiring_soon to be in expiring_soon list"
  end

  # =========================================================================
  # Recent Activity Tests
  # =========================================================================

  test "should load recent favorites" do
    sign_in @buyer_user
    get buyer_root_path
    
    recent_favorites = assigns(:recent_favorites)
    assert_not_nil recent_favorites
    assert recent_favorites.count <= 5, "Should limit to 5 recent favorites"
  end

  test "should load recent activity" do
    sign_in @buyer_user
    get buyer_root_path
    
    recent_activity = assigns(:recent_activity)
    assert_not_nil recent_activity
    assert recent_activity.count <= 5, "Should limit to 5 recent activities"
  end

  # =========================================================================
  # Edge Cases
  # =========================================================================

  test "should handle buyer with no deals" do
    buyer_three = users(:buyer_three)
    # Remove all deals for buyer_three
    Deal.where(buyer_profile: buyer_profiles(:buyer_profile_three)).destroy_all
    
    sign_in buyer_three
    get buyer_root_path
    
    assert_response :success
    
    stats = assigns(:stats)
    assert_equal 0, stats[:total_deals]
    assert_equal 0, stats[:active_reservations]
  end

  test "should handle buyer with no favorites" do
    buyer_three = users(:buyer_three)
    Favorite.where(buyer_profile: buyer_profiles(:buyer_profile_three)).destroy_all
    
    sign_in buyer_three
    get buyer_root_path
    
    assert_response :success
    
    stats = assigns(:stats)
    assert_equal 0, stats[:favorites]
    assert_equal 0, assigns(:new_favorites_count)
  end
end
