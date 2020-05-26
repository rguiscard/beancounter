require 'test_helper'

class ParseServiceTest < ActiveSupport::TestCase
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

    ParseService.parse(content) do |entry|
      assert_equal entry[:name], "Equity:Opening-Balances"
      assert_equal entry[:currency_list], "USD,JPN"
    end
  end

  test "can parse accounts" do
    content = <<~EOF
      1980-05-12 open Liabilities:AccountsPayable
    EOF

    ParseService.parse(content) do |entry|
      assert_equal entry[:name], "Liabilities:AccountsPayable"
      assert entry[:currency_list].blank?
    end
  end

  test "can parse simple transaction" do
    content = file_fixture('simple-transactions.beancount').read
    ParseService.parse(content) do |entry|
#      puts entry
    end
  end
end
