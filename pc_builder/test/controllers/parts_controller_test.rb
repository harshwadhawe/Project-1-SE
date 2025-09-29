require "test_helper"

class PartsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get parts_index_url
    assert_response :success
  end

  test "should get show" do
    get parts_show_url
    assert_response :success
  end
end
