require 'test_helper'

class PostingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @entry = entries(:one)
    @posting = postings(:one)
    sign_in @user
  end

#  test "should get index" do
#    get entry_postings_url(@entry)
#    assert_response :success
#  end

  test "should get new" do
    get new_entry_posting_url(@entry)
    assert_response :success
  end

  test "should create posting" do
    assert_difference('Posting.count') do
      post entry_postings_url(@entry), params: { posting: { account_id: @posting.account_id, arguments: @posting.arguments, comment: @posting.comment, entry_id: @posting.entry_id, flag: @posting.flag } }
    end

    assert_redirected_to entry_posting_url(@entry, @user.postings.last)
  end

  test "should show posting" do
    get entry_posting_url(@entry, @posting)
    assert_response :success
  end

  test "should get edit" do
    get edit_entry_posting_url(@entry, @posting)
    assert_response :success
  end

  test "should update posting" do
    patch entry_posting_url(@entry, @posting), params: { posting: { account: @posting.account, arguments: @posting.arguments, comment: @posting.comment, entry_id: @posting.entry_id, flag: @posting.flag } }
    assert_redirected_to entry_posting_url(@entry, @posting)
  end

  test "should destroy posting" do
    assert_difference('@user.postings.count', -1) do
      delete entry_posting_url(@entry, @posting)
    end

    assert_redirected_to entry_url(@entry)
  end
end
