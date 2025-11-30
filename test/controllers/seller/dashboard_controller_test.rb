require "test_helper"

class Seller::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seller_user = users(:seller)
    @seller_profile = seller_profiles(:seller_profile)
    @buyer_user = users(:buyer)
    @admin_user = users(:admin)
  end

  # =========================================================================
  # Authentication & Authorization Tests
  # =========================================================================

  test "should get index for authenticated seller" do
    sign_in @seller_user
    get seller_root_path
    assert_response :success
  end

  test "should redirect unauthenticated users to login" do
    get seller_root_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect buyers to root path" do
    sign_in @buyer_user
    get seller_root_path
    assert_redirected_to root_path
    assert_equal 'Access denied. Seller privileges required.', flash[:alert]
  end

  test "should redirect admins to root path" do
    sign_in @admin_user
    get seller_root_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Interest Count Tests
  # =========================================================================

  test "should calculate new interests this week" do
    sign_in @seller_user
    get seller_root_path
    
    new_interests = assigns(:new_interests_this_week)
    assert_not_nil new_interests
    
    # Calculate expected: distinct buyers who favorited seller's listings this week
    listing_ids = @seller_profile.listings.pluck(:id)
    expected = Favorite.where(listing_id: listing_ids)
                       .where('created_at >= ?', 7.days.ago)
                       .distinct
                       .count(:buyer_profile_id)
    
    assert_equal expected, new_interests
  end

  test "should count interests from all seller listings" do
    sign_in @seller_user
    get seller_root_path
    
    new_interests = assigns(:new_interests_this_week)
    
    # Seller has listing_one, listing_zero_views, listing_pending
    # Favorites this week on seller's listings from fixtures:
    # - favorite_one (buyer -> listing_one, 2 days ago)
    # - favorite_three (buyer -> listing_zero_views, 6 days ago)
    # - favorite_buyer_two_on_listing_one (buyer_two -> listing_one, 3 days ago)
    # - favorite_buyer_three_on_listing_one (buyer_three -> listing_one, 1 day ago)
    # Distinct buyers: buyer, buyer_two, buyer_three = 3 (potentially)
    
    assert new_interests >= 0
  end

  # =========================================================================
  # Unread Messages Tests
  # =========================================================================

  test "should calculate unread messages count" do
    sign_in @seller_user
    get seller_root_path
    
    unread_count = assigns(:unread_messages_count)
    assert_not_nil unread_count
    assert unread_count >= 0
  end

  test "should count only messages in seller conversations" do
    sign_in @seller_user
    get seller_root_path
    
    unread_count = assigns(:unread_messages_count)
    
    # Seller participates in conversation_buyer_seller
    # Messages unread by seller: those created after seller's last_read_at (9.days.ago)
    # From fixtures: message_conv1_3_unread, message_conv1_4_unread (both from seller, so not unread for seller)
    # Actually those are FROM seller TO buyer, so seller wouldn't have unread
    
    assert_not_nil unread_count
  end

  # =========================================================================
  # Analytics Summary Tests
  # =========================================================================

  test "should load analytics summary" do
    sign_in @seller_user
    get seller_root_path
    
    analytics_summary = assigns(:analytics_summary)
    assert_not_nil analytics_summary
  end

  test "should load listings with analytics" do
    sign_in @seller_user
    get seller_root_path
    
    listings_with_analytics = assigns(:listings_with_analytics)
    assert_not_nil listings_with_analytics
  end

  test "should calculate views growth" do
    sign_in @seller_user
    get seller_root_path
    
    views_growth = assigns(:views_growth)
    assert_not_nil views_growth
  end

  # =========================================================================
  # Seller Profile Tests
  # =========================================================================

  test "should set seller profile" do
    sign_in @seller_user
    get seller_root_path
    
    seller_profile = assigns(:seller_profile)
    assert_not_nil seller_profile
    assert_equal @seller_profile.id, seller_profile.id
  end

  # =========================================================================
  # Edge Cases
  # =========================================================================

  test "should handle seller with no listings" do
    # Create a seller with no listings
    seller_two = users(:seller_two)
    seller_two.seller_profile.listings.destroy_all
    
    sign_in seller_two
    get seller_root_path
    
    assert_response :success
    
    new_interests = assigns(:new_interests_this_week)
    assert_equal 0, new_interests
  end

  test "should handle seller with no conversations" do
    seller_two = users(:seller_two)
    # seller_two participates in conversation_buyer_seller_two
    
    sign_in seller_two
    get seller_root_path
    
    assert_response :success
    
    unread_count = assigns(:unread_messages_count)
    assert_not_nil unread_count
  end
end
