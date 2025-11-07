require "test_helper"

class UnitAvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get unit_availabilities_index_url
    assert_response :success
  end

  test "should get show" do
    get unit_availabilities_show_url
    assert_response :success
  end

  test "should get new" do
    get unit_availabilities_new_url
    assert_response :success
  end

  test "should get edit" do
    get unit_availabilities_edit_url
    assert_response :success
  end
end
