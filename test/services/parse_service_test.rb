require 'test_helper'

class ParseServiceTest < ActiveSupport::TestCase
  test "can parse posting without amount" do
    content = <<~EOF
      2020-05-15 * "信用卡轉帳"
        Liabilities:台灣銀行               225 TWD ; comment
        Income:Cashback
    EOF

    ParseService.parse(content) do |klass, entry|
    end
  end

  test "can validate account" do
    content = file_fixture('open-accounts.beancount').read
    assert_nil ParseService.validate(content)
  end

  test "can validate transaction" do
    content = file_fixture('simple-transactions.beancount').read
    assert_nil ParseService.validate(content)
  end

  test "can parse accounts with currencies" do
    content = <<~EOF
      1980-05-12 open Equity:Opening-Balances USD,JPN
    EOF

    ParseService.parse(content) do |klass, entry|
      assert_equal entry[:name], "Equity:Opening-Balances"
      assert_equal entry[:currency_list], "USD,JPN"
    end
  end

  test "can parse accounts" do
    content = <<~EOF
      1980-05-12 open Liabilities:AccountsPayable
    EOF

    ParseService.parse(content) do |klass, entry|
      assert_equal entry[:name], "Liabilities:AccountsPayable"
      assert entry[:currency_list].blank?
    end
  end

  test "can parse simple transaction" do
    content = file_fixture('simple-transactions.beancount').read
    ParseService.parse(content) do |klass, entry|
#      puts entry
    end
  end
end
