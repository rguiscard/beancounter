require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in @user
  end

  test "should get index" do
    get accounts_url
    assert_response :success
  end

#  test "should get new" do
#    get new_account_url
#    assert_response :success
#  end

#  test "should create account" do
#    assert_difference('Account.count') do
#      post accounts_url, params: { account: { currencies: @account.currencies, name: @account.name } }
#    end
#
#    assert_redirected_to account_url(Account.last)
#  end

  test "should show account" do
    get account_url(@account)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: { account: { currencies: @account.currencies, name: @account.name } }
    assert_redirected_to account_url(@account)
  end

  test "should destroy empty account" do
    @account = @user.accounts.create(name: "New Bank")
    assert_difference('Account.count', -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end

  # Account with postings will be redirect to confirm_destroy_account_path
  test "should destroy account" do
    assert_difference('Account.count', 0) do
      delete account_url(@account)
    end

    assert_redirected_to confirm_destroy_account_url(@account)
  end
end
