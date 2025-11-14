require "test_helper"

class GalleryImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gallery_images_index_url
    assert_response :success
  end

  test "should get show" do
    get gallery_images_show_url
    assert_response :success
  end

  test "should get new" do
    get gallery_images_new_url
    assert_response :success
  end

  test "should get edit" do
    get gallery_images_edit_url
    assert_response :success
  end
end
