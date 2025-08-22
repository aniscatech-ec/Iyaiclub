require "test_helper"

class PlanPricesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get plan_prices_index_url
    assert_response :success
  end

  test "should get new" do
    get plan_prices_new_url
    assert_response :success
  end

  test "should get create" do
    get plan_prices_create_url
    assert_response :success
  end

  test "should get edit" do
    get plan_prices_edit_url
    assert_response :success
  end

  test "should get update" do
    get plan_prices_update_url
    assert_response :success
  end

  test "should get destroy" do
    get plan_prices_destroy_url
    assert_response :success
  end
end
