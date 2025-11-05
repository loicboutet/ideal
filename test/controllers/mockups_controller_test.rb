require "test_helper"

class MockupsControllerTest < ActionDispatch::IntegrationTest
  # Disable fixtures for mockup tests - we don't need real data
  self.use_transactional_tests = false
  
  test "should get index" do
    get mockups_path
    assert_response :success
  end

  test "should get about" do
    get mockups_about_path
    assert_response :success
  end

  test "should get pricing" do
    get mockups_pricing_path
    assert_response :success
  end

  test "should get admin dashboard" do
    get mockups_admin_path
    assert_response :success
  end

  test "should get admin analytics" do
    get mockups_admin_analytics_path
    assert_response :success
  end

  test "should get admin users" do
    get mockups_admin_users_path
    assert_response :success
  end

  test "root should route to mockups overview" do
    get root_path
    assert_response :success
  end
end
