require "test_helper"

class Seller::InterestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seller_user = users(:seller)
    @seller_profile = seller_profiles(:seller_profile)
    @buyer_user = users(:buyer)
    @buyer_profile = buyer_profiles(:buyer_profile)
    @buyer_two = users(:buyer_two)
    @buyer_profile_two = buyer_profiles(:buyer_profile_two)
  end

  # =========================================================================
  # Authentication & Authorization Tests
  # =========================================================================

  test "should get index for authenticated seller" do
    sign_in @seller_user
    get seller_interests_path
    assert_response :success
  end

  test "should redirect unauthenticated users to login" do
    get seller_interests_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect buyers accessing seller interests" do
    sign_in @buyer_user
    get seller_interests_path
    assert_redirected_to root_path
    assert_equal 'Accès refusé. Privilèges vendeur requis.', flash[:alert]
  end

  test "should redirect admins accessing seller interests" do
    sign_in users(:admin)
    get seller_interests_path
    assert_redirected_to root_path
  end

  test "should redirect partners accessing seller interests" do
    sign_in users(:partner)
    get seller_interests_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Index - Interests List Tests
  # =========================================================================

  test "should list buyers who favorited seller listings" do
    sign_in @seller_user
    get seller_interests_path
    
    interests = assigns(:interests)
    assert_not_nil interests
    assert_kind_of Array, interests
    
    # Each interest should have required structure
    interests.each do |interest|
      assert interest.key?(:buyer_profile), "Interest missing buyer_profile"
      assert interest.key?(:favorites_count), "Interest missing favorites_count"
      assert interest.key?(:listings), "Interest missing listings"
      assert interest.key?(:favorited_at), "Interest missing favorited_at"
      assert interest.key?(:has_deal), "Interest missing has_deal"
    end
  end

  test "should calculate stats correctly" do
    sign_in @seller_user
    get seller_interests_path
    
    stats = assigns(:stats)
    assert_not_nil stats
    
    assert stats.key?(:total_interested), "Stats missing total_interested"
    assert stats.key?(:this_week), "Stats missing this_week"
    assert stats.key?(:active_negotiations), "Stats missing active_negotiations"
  end

  test "should count total interested buyers" do
    sign_in @seller_user
    get seller_interests_path
    
    stats = assigns(:stats)
    interests = assigns(:interests)
    
    assert_equal interests.count, stats[:total_interested]
  end

  test "should count interests this week" do
    sign_in @seller_user
    get seller_interests_path
    
    stats = assigns(:stats)
    interests = assigns(:interests)
    
    # Count interests where favorited_at is within 7 days
    expected_this_week = interests.count { |i| i[:favorited_at] >= 7.days.ago }
    assert_equal expected_this_week, stats[:this_week]
  end

  test "should count active negotiations" do
    sign_in @seller_user
    get seller_interests_path
    
    stats = assigns(:stats)
    
    # Active negotiations = deals in negociation, loi, audits, or financement stages
    listing_ids = @seller_profile.listings.pluck(:id)
    expected = Deal.where(listing_id: listing_ids)
                   .where(status: [:negotiation, :loi, :audits, :financing])
                   .count
    
    assert_equal expected, stats[:active_negotiations]
  end

  test "should sort interests by most recent favorited_at" do
    sign_in @seller_user
    get seller_interests_path
    
    interests = assigns(:interests)
    
    # Verify sorted by favorited_at descending
    sorted = interests.each_cons(2).all? do |a, b|
      a[:favorited_at].to_i >= b[:favorited_at].to_i
    end
    
    assert sorted || interests.length <= 1, "Interests should be sorted by favorited_at descending"
  end

  # =========================================================================
  # Show - Buyer Profile Tests
  # =========================================================================

  test "should get show for buyer who favorited listings" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile)
    assert_response :success
  end

  test "should display buyer profile details" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile)
    
    buyer_profile = assigns(:buyer_profile)
    assert_not_nil buyer_profile
    assert_equal @buyer_profile.id, buyer_profile.id
  end

  test "should list favorites on seller listings" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile)
    
    favorites = assigns(:favorites)
    assert_not_nil favorites
    
    # All favorites should be on seller's listings
    seller_listing_ids = @seller_profile.listings.pluck(:id)
    favorites.each do |favorite|
      assert seller_listing_ids.include?(favorite.listing_id),
             "Favorite #{favorite.id} is not on seller's listing"
    end
  end

  test "should list deals between buyer and seller" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile)
    
    deals = assigns(:deals)
    assert_not_nil deals
    
    # All deals should involve seller's listings
    seller_listing_ids = @seller_profile.listings.pluck(:id)
    deals.each do |deal|
      assert seller_listing_ids.include?(deal.listing_id),
             "Deal #{deal.id} is not on seller's listing"
    end
  end

  test "should determine can_contact status" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile)
    
    can_contact = assigns(:can_contact)
    assert_not_nil can_contact
    
    # Seller can contact if has >= 5 credits OR is premium
    expected = @seller_profile.credits >= 5 || @seller_profile.subscription_plan == 'premium'
    assert_equal expected, can_contact
  end

  test "should show buyer profile by id" do
    sign_in @seller_user
    get seller_interest_path(@buyer_profile_two)
    
    assert_response :success
    buyer_profile = assigns(:buyer_profile)
    assert_equal @buyer_profile_two.id, buyer_profile.id
  end

  # =========================================================================
  # Authorization - Show Tests
  # =========================================================================

  test "should redirect unauthenticated users from show" do
    get seller_interest_path(@buyer_profile)
    assert_redirected_to new_user_session_path
  end

  test "should redirect buyers from show" do
    sign_in @buyer_user
    get seller_interest_path(@buyer_profile)
    assert_redirected_to root_path
  end

  # =========================================================================
  # Edge Cases
  # =========================================================================

  test "should handle seller with no interested buyers" do
    seller_two = users(:seller_two)
    # Remove all favorites on seller_two's listings
    seller_two_profile = seller_profiles(:seller_profile_two)
    listing_ids = seller_two_profile.listings.pluck(:id)
    Favorite.where(listing_id: listing_ids).destroy_all
    
    sign_in seller_two
    get seller_interests_path
    
    assert_response :success
    
    interests = assigns(:interests)
    assert_empty interests
    
    stats = assigns(:stats)
    assert_equal 0, stats[:total_interested]
    assert_equal 0, stats[:this_week]
  end

  test "should handle buyer with no favorites on seller listings" do
    sign_in @seller_user
    
    # buyer_three has no favorites on seller's listings in our setup
    buyer_three = buyer_profiles(:buyer_profile_three)
    
    get seller_interest_path(buyer_three)
    
    assert_response :success
    
    favorites = assigns(:favorites)
    # Should return empty or only seller's listings favorites
    favorites.each do |fav|
      seller_listing_ids = @seller_profile.listings.pluck(:id)
      assert seller_listing_ids.include?(fav.listing_id)
    end
  end

  test "should handle buyer with no deals with seller" do
    sign_in @seller_user
    
    buyer_three = buyer_profiles(:buyer_profile_three)
    # buyer_three might have deals but not necessarily with this seller's listings
    
    get seller_interest_path(buyer_three)
    
    assert_response :success
    
    deals = assigns(:deals)
    assert_not_nil deals
  end

  test "should return 404 for nonexistent buyer profile" do
    sign_in @seller_user
    
    get seller_interest_path(id: 99999)
    
    # Should return 404 either via exception or redirect
    assert_response :not_found rescue assert_redirected_to seller_interests_path
  end
end
