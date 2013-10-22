require 'test_helper'

class OuterControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
    assert_select 'h1', "Outer#show"
    assert_select 'h2', "Inner#show"
  end

end
