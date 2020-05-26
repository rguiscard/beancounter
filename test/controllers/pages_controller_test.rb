require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get beancount" do
    get pages_beancount_url
    assert_response :success
  end

end
