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

  test "should get new" do
    get new_account_url
    assert_response :success
  end

  test "should create account" do
    bank = "Assets::BankOne"
    assert_difference -> { Account.count } => 1, -> { Entry.count } => 1 do
      post accounts_url, params: { account: { currencies: @account.currencies, name: bank } }
    end

    assert_redirected_to account_url(Account.find_by(name: bank))
  end

  test "should create account with balance" do
    bank = "Assets::BankOne"
    balance = "1000 USD"
    assert_difference -> { Account.count } => 2, -> { Entry.count } => 4 do
      post accounts_url, params: { account: { currencies: @account.currencies, name: bank }, balance: balance }
    end

    assert Entry.pad.find_by(arguments: "#{bank} Equity:Setup").present?
    assert Entry.balance.find_by(arguments: "#{bank} #{balance}").present?

    assert_redirected_to account_url(Account.find_by(name: bank))
  end

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
