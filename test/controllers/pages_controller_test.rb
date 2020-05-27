require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "should create entry" do
    assert_difference ['Entry.count', 'Account.count']  do
      post pages_import_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_redirected_to entries_url
  end
end
