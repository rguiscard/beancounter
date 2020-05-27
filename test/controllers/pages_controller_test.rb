require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
  end

  test "should create entry and postings without amount" do
    content = <<~EOF
      2020-05-15 * "信用卡轉帳"
        Liabilities:台灣銀行               225 TWD
        Income:Cashback
    EOF

    Account.create(name: "Liabilities:三商台新")
    Account.create(name: "Income:Cashback")

    assert_difference -> { Entry.count } => 1, -> { Posting.count } => 2 do
      post pages_import_url, params: { content: content }
    end

    assert_equal Entry.last.postings.count, 2
    assert_equal Entry.last.postings.last.account, Account.find_by(name: "Income:Cashback")

    assert_redirected_to entries_url
  end

  test "should create account" do
    assert_difference ['Entry.count', 'Account.count']  do
      post pages_import_url, params: { content: "2015-01-01 open Assets:BoA USD" }
    end

    assert_equal Account.last.name, "Assets:BoA"

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

    assert_difference -> { Entry.count } => 3, -> { Posting.count } => 4 do
      post pages_import_url, params: { content: content }
    end

    assert_equal Entry.last.postings.count, 2
    assert_equal Entry.last.postings.last.account, Account.find_by(name: "Expenses:Financial:Fees")

    assert_redirected_to entries_url
  end
end
