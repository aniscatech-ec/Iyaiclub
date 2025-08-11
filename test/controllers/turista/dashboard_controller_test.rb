require "test_helper"

class Turista::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get turista_dashboard_index_url
    assert_response :success
  end
end
