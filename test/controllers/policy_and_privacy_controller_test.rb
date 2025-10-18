require "test_helper"

class PolicyAndPrivacyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get policy_and_privacy_index_url
    assert_response :success
  end
end
