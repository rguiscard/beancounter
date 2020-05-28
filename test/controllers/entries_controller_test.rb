require 'test_helper'

class EntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @entry = entries(:one)
    sign_in @user
  end

  test "should get index" do
    get entries_url
    assert_response :success
  end

  test "should get new" do
    get new_entry_url
    assert_response :success
  end

  test "should create entry" do
    assert_difference('@user.entries.count') do
      post entries_url, params: { entry: { arguments: @entry.arguments, date: @entry.date, directive: @entry.directive } }
    end

    assert_redirected_to entry_url(@user.entries.last)
  end

  test "should show entry" do
    get entry_url(@entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_entry_url(@entry)
    assert_response :success
  end

  test "should update entry" do
    patch entry_url(@entry), params: { entry: { arguments: @entry.arguments, date: @entry.date, directive: @entry.directive } }
    assert_redirected_to entry_url(@entry)
  end

  test "should destroy entry" do
    assert_difference('@user.entries.count', -1) do
      delete entry_url(@entry)
    end

    assert_redirected_to entries_url
  end
end
