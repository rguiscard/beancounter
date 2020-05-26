require 'test_helper'

class PostingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @posting = postings(:one)
  end

  test "should get index" do
    get postings_url
    assert_response :success
  end

  test "should get new" do
    get new_posting_url
    assert_response :success
  end

  test "should create posting" do
    assert_difference('Posting.count') do
      post postings_url, params: { posting: { account: @posting.account, arguments: @posting.arguments, comment: @posting.comment, entry_id: @posting.entry_id, flag: @posting.flag } }
    end

    assert_redirected_to posting_url(Posting.last)
  end

  test "should show posting" do
    get posting_url(@posting)
    assert_response :success
  end

  test "should get edit" do
    get edit_posting_url(@posting)
    assert_response :success
  end

  test "should update posting" do
    patch posting_url(@posting), params: { posting: { account: @posting.account, arguments: @posting.arguments, comment: @posting.comment, entry_id: @posting.entry_id, flag: @posting.flag } }
    assert_redirected_to posting_url(@posting)
  end

  test "should destroy posting" do
    assert_difference('Posting.count', -1) do
      delete posting_url(@posting)
    end

    assert_redirected_to postings_url
  end
end
