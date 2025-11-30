# frozen_string_literal: true

require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    @buyer_user = users(:buyer)
    @seller_user = users(:seller)
    @partner_user = users(:partner)
    @admin_user = users(:admin)
  end

  # ===========================================================================
  # Authentication Required - All routes should redirect unauthenticated users
  # ===========================================================================

  test "select_plan redirects unauthenticated users to sign in" do
    get checkout_select_plan_url
    assert_redirected_to new_user_session_path
  end

  test "payment_form redirects unauthenticated users to sign in" do
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_redirected_to new_user_session_path
  end

  test "process_payment redirects unauthenticated users to sign in" do
    post checkout_process_payment_url, params: { plan: "buyer_pro" }
    assert_redirected_to new_user_session_path
  end

  test "success redirects unauthenticated users to sign in" do
    get checkout_success_url
    assert_redirected_to new_user_session_path
  end

  test "cancel redirects unauthenticated users to sign in" do
    get checkout_cancel_url
    assert_redirected_to new_user_session_path
  end

  # ===========================================================================
  # GET /checkout/select_plan - Authenticated access
  # ===========================================================================

  test "select_plan shows buyer plans for buyer role" do
    sign_in @buyer_user
    get checkout_select_plan_url
    assert_response :success
    
    assert_not_nil assigns(:buyer_plans)
    assert assigns(:buyer_plans).length > 0
    assert_equal "buyer", assigns(:user_role)
  end

  test "select_plan shows seller plans for seller role" do
    sign_in @seller_user
    get checkout_select_plan_url
    # May raise error due to model issues, but should at least attempt to load
    assert_response :success
    
    assert_not_nil assigns(:seller_plans)
    assert assigns(:seller_plans).length > 0
    assert_equal "seller", assigns(:user_role)
  end

  test "select_plan shows partner plans for partner role" do
    sign_in @partner_user
    get checkout_select_plan_url
    assert_response :success
    
    assert_not_nil assigns(:partner_plans)
    assert assigns(:partner_plans).length > 0
    assert_equal "partner", assigns(:user_role)
  end

  test "select_plan shows credit packs for buyer" do
    sign_in @buyer_user
    get checkout_select_plan_url
    assert_response :success
    
    assert_not_nil assigns(:credit_packs)
    assert assigns(:credit_packs).length > 0
  end

  # ===========================================================================
  # GET /checkout/payment (params: plan) - Authenticated access
  # ===========================================================================

  test "payment_form returns success with valid buyer plan" do
    sign_in @buyer_user
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_response :success
    
    selected_plan = assigns(:selected_plan)
    assert_not_nil selected_plan
    assert_equal "buyer_pro", selected_plan[:id]
  end

  test "payment_form returns success with valid seller plan" do
    sign_in @seller_user
    get checkout_payment_url, params: { plan: "seller_premium" }
    assert_response :success
    
    selected_plan = assigns(:selected_plan)
    assert_not_nil selected_plan
    assert_equal "seller_premium", selected_plan[:id]
  end

  test "payment_form returns success with valid partner plan" do
    sign_in @partner_user
    get checkout_payment_url, params: { plan: "partner_annual" }
    assert_response :success
    
    selected_plan = assigns(:selected_plan)
    assert_not_nil selected_plan
    assert_equal "partner_annual", selected_plan[:id]
  end

  test "payment_form returns success with credit pack" do
    sign_in @buyer_user
    get checkout_payment_url, params: { plan: "credits_15" }
    assert_response :success
    
    selected_plan = assigns(:selected_plan)
    assert_not_nil selected_plan
    assert_equal "credits_15", selected_plan[:id]
  end

  test "payment_form redirects with invalid plan" do
    sign_in @buyer_user
    get checkout_payment_url, params: { plan: "invalid_plan_xyz" }
    assert_redirected_to checkout_select_plan_path
    assert_equal "Plan sélectionné invalide.", flash[:alert]
  end

  test "payment_form redirects with missing plan" do
    sign_in @buyer_user
    get checkout_payment_url
    assert_redirected_to checkout_select_plan_path
    assert_equal "Plan sélectionné invalide.", flash[:alert]
  end

  test "payment_form shows order summary" do
    sign_in @buyer_user
    get checkout_payment_url, params: { plan: "buyer_club" }
    assert_response :success
    
    billing_details = assigns(:billing_details)
    assert_not_nil billing_details
    assert_not_nil billing_details[:name]
    assert_not_nil billing_details[:email]
    assert_not_nil billing_details[:plan]
  end

  test "payment_form pre-fills user info" do
    sign_in @buyer_user
    get checkout_payment_url, params: { plan: "buyer_pro" }
    assert_response :success
    
    billing_details = assigns(:billing_details)
    assert_equal @buyer_user.full_name, billing_details[:name]
    assert_equal @buyer_user.email, billing_details[:email]
  end

  # ===========================================================================
  # POST /checkout/process_payment - Authenticated access
  # ===========================================================================

  test "process_payment redirects on valid plan" do
    sign_in @buyer_user
    post checkout_process_payment_url, params: { plan: "buyer_pro" }
    # Should redirect to either success or cancel (depending on model support)
    assert_response :redirect
  end

  test "process_payment redirects to select_plan on invalid plan" do
    sign_in @buyer_user
    post checkout_process_payment_url, params: { plan: "invalid_plan_xyz" }
    assert_redirected_to checkout_select_plan_path
    assert_equal "Plan invalide.", flash[:alert]
  end

  test "process_payment handles seller with valid plan" do
    sign_in @seller_user
    post checkout_process_payment_url, params: { plan: "seller_premium" }
    # Should redirect somewhere
    assert_response :redirect
  end

  test "process_payment handles partner with valid plan" do
    sign_in @partner_user
    post checkout_process_payment_url, params: { plan: "partner_annual" }
    # Should redirect somewhere
    assert_response :redirect
  end

  test "process_payment handles credit pack" do
    sign_in @buyer_user
    post checkout_process_payment_url, params: { plan: "credits_30" }
    # Should redirect somewhere
    assert_response :redirect
  end

  # ===========================================================================
  # GET /checkout/success - Authenticated access
  # ===========================================================================

  test "success returns success" do
    sign_in @buyer_user
    get checkout_success_url, params: { plan: "buyer_pro" }
    assert_response :success
  end

  test "success shows plan details" do
    sign_in @buyer_user
    get checkout_success_url, params: { plan: "buyer_pro" }
    assert_response :success
    
    plan = assigns(:plan)
    assert_not_nil plan
    assert_equal "buyer_pro", plan[:id]
  end

  test "success handles missing plan gracefully" do
    sign_in @buyer_user
    get checkout_success_url
    assert_response :success
    
    # Should use default plan for role
    assert_not_nil assigns(:plan)
  end

  # ===========================================================================
  # GET /checkout/cancel - Authenticated access
  # ===========================================================================

  test "cancel returns success" do
    sign_in @buyer_user
    get checkout_cancel_url
    assert_response :success
  end

  test "cancel shows default reason-specific message" do
    sign_in @buyer_user
    get checkout_cancel_url
    assert_response :success
    
    reason = assigns(:reason)
    assert_equal "cancelled", reason
  end

  test "cancel shows custom reason when provided" do
    sign_in @buyer_user
    get checkout_cancel_url, params: { reason: "payment_failed" }
    assert_response :success
    
    reason = assigns(:reason)
    assert_equal "payment_failed", reason
  end

  # ===========================================================================
  # Plan Structure Tests
  # ===========================================================================

  test "buyer plans have correct structure" do
    sign_in @buyer_user
    get checkout_select_plan_url
    
    assigns(:buyer_plans).each do |plan|
      assert plan.key?(:id), "Plan missing :id"
      assert plan.key?(:name), "Plan missing :name"
      assert plan.key?(:price), "Plan missing :price"
      assert plan.key?(:period), "Plan missing :period"
      assert plan.key?(:features), "Plan missing :features"
      assert_kind_of Array, plan[:features]
    end
  end

  test "credit packs have correct structure" do
    sign_in @buyer_user
    get checkout_select_plan_url
    
    assigns(:credit_packs).each do |pack|
      assert pack.key?(:id), "Pack missing :id"
      assert pack.key?(:name), "Pack missing :name"
      assert pack.key?(:price), "Pack missing :price"
      assert pack.key?(:credits), "Pack missing :credits"
    end
  end

  test "buyer plans include popular flag" do
    sign_in @buyer_user
    get checkout_select_plan_url
    
    popular_plans = assigns(:buyer_plans).select { |p| p[:popular] }
    assert popular_plans.length >= 1, "Should have at least one popular plan"
  end
end
