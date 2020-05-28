require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should create entry and postings without amount" do
    content = <<~EOF
      2020-05-15 * "信用卡轉帳"
        Liabilities:台灣銀行               225 TWD
        Income:Cashback
    EOF

    @user.accounts.create(name: "Liabilities:台灣銀行")
    @user.accounts.create(name: "Income:Cashback")

    assert_difference -> { @user.entries.count } => 1, -> { @user.postings.count } => 2 do
      post pages_import_url, params: { content: content }
    end

    assert_equal @user.entries.last.postings.count, 2
    assert_equal @user.entries.last.postings.last.account, @user.accounts.find_by(name: "Income:Cashback")

    assert_redirected_to entries_url
  end

  test "should create account" do
    assert_difference ['@user.entries.count', '@user.accounts.count']  do
      post pages_import_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_equal @user.accounts.last.name, "Assets:BoA"

    assert_redirected_to entries_url
  end

  test "should create entry and postings" do
    content = <<~EOF
      2018-01-01 * "Opening Balance for checking account"
        Assets:US:BofA:Checking                         3614.47 USD
        Equity:Opening-Balances                        -3614.47 USD

      2018-01-02 balance Assets:US:BofA:Checking        3614.47 USD

      2018-01-04 * "BANK FEES" "Monthly bank fee"
        Assets:US:BofA:Checking                           -4.00 USD
        Expenses:Financial:Fees                            4.00 USD

    EOF

    assert_difference -> { @user.entries.count } => 3, -> { @user.postings.count } => 4 do
      post pages_import_url, params: { content: content }
    end

    assert_equal @user.entries.last.postings.count, 2
    assert_equal @user.entries.last.postings.last.account, @user.accounts.find_by(name: "Expenses:Financial:Fees")

    assert_redirected_to entries_url
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
