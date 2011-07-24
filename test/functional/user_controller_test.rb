require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get giris" do
    get :giris
    assert_response :success
  end

end
