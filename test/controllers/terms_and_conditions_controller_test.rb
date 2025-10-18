require "test_helper"

class TermsAndConditionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get terms_and_conditions_index_url
    assert_response :success
  end
end
