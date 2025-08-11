require "test_helper"

class Afiliado::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get afiliado_dashboard_index_url
    assert_response :success
  end
end
