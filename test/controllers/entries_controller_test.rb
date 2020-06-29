require 'test_helper'

class EntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @entry = entries(:one)
    sign_in @user
  end

  test "create tags" do
    content = <<~EOF
      2020-05-16 * "Bank transfer" #2020_winter #2021-spring ^my-business; comment
        Liabilities:NewBank               100 USD
        Income:Cashback
    EOF

    assert_difference -> { @user.entries.count } => 1 do
      post import_entries_url, params: { content: content, create_account: 0 }
    end

    entry = @user.entries.last
    assert_includes entry.tags, "2020_winter"
    assert_includes entry.tags, "2021-spring"
    refute_includes entry.tags, "2022-spring"
    assert_includes entry.links, "my-business"
  end

  test "cannot create accounts with new postings" do
    content = <<~EOF
      2020-05-16 * "信用卡轉帳"
        Liabilities:NewBank               100 USD
        Income:Cashback
    EOF

    assert_difference -> { @user.entries.count } => 1, -> { @user.postings.count } => 0, -> { @user.accounts.count } => 0 do
      post import_entries_url, params: { content: content, create_account: 0 }
    end

    refute @user.accounts.find_by(name: "Liabilities:NewBank").present?
    refute @user.accounts.find_by(name: "Income:Cashback").present?

    entry = @user.entries.find_by(arguments: "\"信用卡轉帳\"")
    assert_equal entry.postings.count, 0

    assert_redirected_to root_url
  end

  test "should automatically create accounts with new postings" do
    content = <<~EOF
      2020-05-16 * "信用卡轉帳"
        Liabilities:NewBank               100 USD
        Income:Cashback
    EOF

    assert_difference -> { @user.entries.count } => 3, -> { @user.postings.count } => 2, -> { @user.accounts.count } => 2 do
      post import_entries_url, params: { content: content, create_account: 1 }
    end

    assert @user.accounts.find_by(name: "Liabilities:NewBank").present?
    assert @user.accounts.find_by(name: "Income:Cashback").present?

    entry = @user.entries.find_by(arguments: "\"信用卡轉帳\"")
    assert_equal entry.postings.count, 2
    assert_equal entry.postings.last.account, @user.accounts.find_by(name: "Income:Cashback")

    assert_redirected_to root_url
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
      post import_entries_url, params: { content: content }
    end

    assert_equal @user.entries.last.postings.count, 2
    assert_equal @user.entries.last.postings.last.account, @user.accounts.find_by(name: "Income:Cashback")

    assert_redirected_to root_url
  end

  test "should create account" do
    assert_difference ['@user.entries.count', '@user.accounts.count']  do
      post import_entries_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_equal @user.accounts.last.name, "Assets:BoA"

    assert_redirected_to root_url
  end

  test "should not create duplicated account" do
    assert_difference ['@user.entries.count', '@user.accounts.count']  do
      post import_entries_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_equal @user.accounts.last.name, "Assets:BoA"

    assert_difference -> { @user.entries.count } => 1, -> { @user.accounts.count } => 0 do
      post import_entries_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_redirected_to root_url
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
      post import_entries_url, params: { content: content }
    end

    assert_equal @user.entries.last.postings.count, 2
    assert_equal @user.entries.last.postings.last.account, @user.accounts.find_by(name: "Expenses:Financial:Fees")

    assert_redirected_to root_url
  end

  test "should get index" do
    get entries_url
    assert_response :success
  end

  test "should get new" do
    get new_entry_url
    assert_response :success
  end

  test "should create entry with currency appended" do
    assert_difference('@user.entries.count') do
      post entries_url, params: { entry: { arguments: "Buy fruit 1543", date: @entry.date, directive: "txn", postings_attributes: {"0" => {account_id: accounts(:one).id, arguments: "123"}, "1" => {account_id: accounts(:one).id}} } }
    end

    entry = Entry.find_by(arguments: "\"Buy fruit 1543\"")
    assert_includes entry.postings.pluck(:arguments), "123 USD"

    assert_redirected_to entry_url(@user.entries.last)
  end

  test "should create entry" do
    assert_difference('@user.entries.count') do
      post entries_url, params: { entry: { arguments: @entry.arguments, date: @entry.date, directive: @entry.directive } }
    end

    assert_redirected_to entry_url(@user.entries.last)
  end

  test "should create entry with quotated arguments" do
    assert_difference('@user.entries.count') do
      post entries_url, params: { entry: { arguments: "abc", date: @entry.date, directive: @entry.directive } }
    end

    assert_equal @user.entries.last.arguments, "\"abc\""

    assert_redirected_to entry_url(@user.entries.last)
  end

  test "should create entry with unmodified arguments" do
    assert_difference('@user.entries.count') do
      post entries_url, params: { entry: { arguments: "Assets:BoA 10000 USD", date: @entry.date, directive: "balance" } }
    end

    assert_equal @user.entries.last.arguments, "Assets:BoA 10000 USD"
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
    patch entry_url(@entry), params: { entry: { arguments: "abc", date: @entry.date, directive: @entry.directive } }
    assert_equal "\"abc\"", Entry.find(@entry.id).arguments
    assert_redirected_to entry_url(@entry)
  end

  test "should destroy entry" do
    assert_difference('@user.entries.count', -1) do
      delete entry_url(@entry)
    end

    assert_redirected_to root_url
  end
end
