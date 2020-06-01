require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "cannot access without sign in" do
    sign_out @user
    get beancount_url
    assert_response :redirect
  end

  test "can access with sign in" do
    get beancount_url
    assert_response :success
  end
end
