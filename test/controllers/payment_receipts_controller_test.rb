require "test_helper"

class PaymentReceiptsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get payment_receipts_index_url
    assert_response :success
  end

  test "should get new" do
    get payment_receipts_new_url
    assert_response :success
  end

  test "should get show" do
    get payment_receipts_show_url
    assert_response :success
  end

  test "should get edit" do
    get payment_receipts_edit_url
    assert_response :success
  end
end
