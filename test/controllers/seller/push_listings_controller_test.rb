require "test_helper"

class Seller::PushListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seller_user = users(:seller)
    @seller_profile = seller_profiles(:seller_profile)
    @buyer_user = users(:buyer)
    @buyer_profile = buyer_profiles(:buyer_profile)
    @buyer_profile_two = buyer_profiles(:buyer_profile_two)
    @listing = listings(:listing_one)
  end

  # =========================================================================
  # Authentication & Authorization Tests
  # =========================================================================

  test "should get index for authenticated seller" do
    sign_in @seller_user
    get seller_push_listings_path
    assert_response :success
  end

  test "should redirect unauthenticated users to login" do
    get seller_push_listings_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect buyers to root path" do
    sign_in @buyer_user
    get seller_push_listings_path
    assert_redirected_to root_path
    assert_equal 'Accès refusé. Privilèges vendeur requis.', flash[:alert]
  end

  test "should redirect admins to root path" do
    sign_in users(:admin)
    get seller_push_listings_path
    assert_redirected_to root_path
  end

  # =========================================================================
  # Index - Display Tests
  # =========================================================================

  test "should display seller credit balance" do
    sign_in @seller_user
    get seller_push_listings_path
    
    credits = assigns(:credits)
    assert_not_nil credits
    assert_equal @seller_profile.credits, credits
  end

  test "should list buyers who favorited seller listings" do
    sign_in @seller_user
    get seller_push_listings_path
    
    interested_buyers = assigns(:interested_buyers)
    assert_not_nil interested_buyers
    assert_kind_of Array, interested_buyers
    
    # Each interested buyer should have required structure
    interested_buyers.each do |buyer|
      assert buyer.key?(:buyer_profile), "Missing buyer_profile"
      assert buyer.key?(:favorites_count), "Missing favorites_count"
      assert buyer.key?(:listings), "Missing listings"
      assert buyer.key?(:subscription_plan), "Missing subscription_plan"
    end
  end

  test "should list seller active listings" do
    sign_in @seller_user
    get seller_push_listings_path
    
    listings = assigns(:listings)
    assert_not_nil listings
    
    # Should only include active listings from this seller
    listings.each do |listing|
      assert_equal @seller_profile.id, listing.seller_profile_id
      assert_equal 'active', listing.status
    end
  end

  # =========================================================================
  # Create - Success Tests
  # =========================================================================

  test "should deduct credits and process push" do
    sign_in @seller_user
    
    initial_credits = @seller_profile.credits
    buyer_ids = [@buyer_profile.id.to_s, @buyer_profile_two.id.to_s]
    
    assert_difference -> { @seller_profile.reload.credits }, -2 do
      post seller_push_listings_path, params: {
        buyer_ids: buyer_ids,
        listing_id: @listing.id
      }
    end
    
    assert_redirected_to seller_push_listings_path
    assert_match /Annonce poussée avec succès/, flash[:notice]
    assert_match /2 repreneur/, flash[:notice]
    assert_match /2 crédit/, flash[:notice]
  end

  test "should push to single buyer" do
    sign_in @seller_user
    
    assert_difference -> { @seller_profile.reload.credits }, -1 do
      post seller_push_listings_path, params: {
        buyer_ids: [@buyer_profile.id.to_s],
        listing_id: @listing.id
      }
    end
    
    assert_redirected_to seller_push_listings_path
    assert_match /1 repreneur/, flash[:notice]
  end

  # =========================================================================
  # Create - Failure Tests
  # =========================================================================

  test "should fail if insufficient credits" do
    sign_in @seller_user
    
    # Set credits to 0
    @seller_profile.update!(credits: 0)
    
    assert_no_difference -> { @seller_profile.reload.credits } do
      post seller_push_listings_path, params: {
        buyer_ids: [@buyer_profile.id.to_s],
        listing_id: @listing.id
      }
    end
    
    assert_redirected_to seller_push_listings_path
    assert_match /Crédits insuffisants/, flash[:alert]
    assert_match /0 crédits/, flash[:alert]
    assert_match /il vous en faut 1/, flash[:alert]
  end

  test "should fail if not enough credits for multiple buyers" do
    sign_in @seller_user
    
    # Set credits to 1 (need 2 for 2 buyers)
    @seller_profile.update!(credits: 1)
    
    assert_no_difference -> { @seller_profile.reload.credits } do
      post seller_push_listings_path, params: {
        buyer_ids: [@buyer_profile.id.to_s, @buyer_profile_two.id.to_s],
        listing_id: @listing.id
      }
    end
    
    assert_redirected_to seller_push_listings_path
    assert_match /Crédits insuffisants/, flash[:alert]
    assert_match /1 crédits/, flash[:alert]
    assert_match /il vous en faut 2/, flash[:alert]
  end

  test "should fail if no buyers selected" do
    sign_in @seller_user
    
    initial_credits = @seller_profile.credits
    
    post seller_push_listings_path, params: {
      buyer_ids: [],
      listing_id: @listing.id
    }
    
    assert_redirected_to seller_push_listings_path
    # An alert should be shown (either one depending on controller flow)
    assert flash[:alert].present?
    assert_equal initial_credits, @seller_profile.reload.credits
  end

  test "should fail if buyer_ids param is missing" do
    sign_in @seller_user
    
    post seller_push_listings_path, params: {
      listing_id: @listing.id
    }
    
    assert_redirected_to seller_push_listings_path
    assert flash[:alert].present?
  end

  test "should fail if listing not found" do
    sign_in @seller_user
    
    initial_credits = @seller_profile.credits
    
    post seller_push_listings_path, params: {
      buyer_ids: [@buyer_profile.id.to_s],
      listing_id: 99999
    }
    
    assert_redirected_to seller_push_listings_path
    assert_equal 'Annonce non trouvée.', flash[:alert]
    assert_equal initial_credits, @seller_profile.reload.credits
  end

  test "should fail if listing belongs to another seller" do
    sign_in @seller_user
    
    # listing_two belongs to seller_two
    other_listing = listings(:listing_two)
    initial_credits = @seller_profile.credits
    
    post seller_push_listings_path, params: {
      buyer_ids: [@buyer_profile.id.to_s],
      listing_id: other_listing.id
    }
    
    assert_redirected_to seller_push_listings_path
    assert_equal 'Annonce non trouvée.', flash[:alert]
    assert_equal initial_credits, @seller_profile.reload.credits
  end

  # =========================================================================
  # Create - Edge Cases
  # =========================================================================

  test "should handle invalid buyer ids gracefully" do
    sign_in @seller_user
    
    # Mix of valid and invalid IDs
    post seller_push_listings_path, params: {
      buyer_ids: [@buyer_profile.id.to_s, "99999", "invalid"],
      listing_id: @listing.id
    }
    
    # Should process valid buyers, skip invalid ones
    # Only 1 valid buyer, so 1 credit should be deducted
    assert_redirected_to seller_push_listings_path
  end

  test "should handle all invalid buyer ids" do
    sign_in @seller_user
    
    initial_credits = @seller_profile.credits
    
    post seller_push_listings_path, params: {
      buyer_ids: ["99999", "88888"],
      listing_id: @listing.id
    }
    
    assert_redirected_to seller_push_listings_path
    # When all buyers are invalid, returns 'Aucun repreneur valide sélectionné.'
    assert_equal 'Aucun repreneur valide sélectionné.', flash[:alert]
  end

  test "should handle empty string buyer ids" do
    sign_in @seller_user
    
    post seller_push_listings_path, params: {
      buyer_ids: ["", ""],
      listing_id: @listing.id
    }
    
    assert_redirected_to seller_push_listings_path
    # Controller returns an alert when all IDs are invalid/empty
    assert flash[:alert].present?
  end

  # =========================================================================
  # Authorization - Create Tests
  # =========================================================================

  test "should not allow buyers to create push" do
    sign_in @buyer_user
    
    post seller_push_listings_path, params: {
      buyer_ids: [@buyer_profile.id.to_s],
      listing_id: @listing.id
    }
    
    assert_redirected_to root_path
  end

  test "should not allow unauthenticated create" do
    post seller_push_listings_path, params: {
      buyer_ids: [@buyer_profile.id.to_s],
      listing_id: @listing.id
    }
    
    assert_redirected_to new_user_session_path
  end
end
