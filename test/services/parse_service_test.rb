require 'test_helper'

class ParseServiceTest < ActiveSupport::TestCase
  test "can parse tag and link" do
    content = <<~EOF
      2020-05-15 * "Bank transfer" #2020-business #transfer ^my-own
        Liabilities:BankOne               225 TWD ; comment
        Income:Cashback
    EOF

    ParseService.parse(content) do |klass, entry|
      case klass
      when :entry
        assert_includes entry[:tags], "2020-business"
        assert_includes entry[:tags], "transfer"
        assert_includes entry[:links], "my-own"
      end
    end
  end

  test "can parse meta from entry" do
    content = <<~EOF
      2020-05-15 * "Bank transfer"
        meta: "information"
        Liabilities:BankOne               225 TWD ; comment
        Income:Cashback
    EOF

    ParseService.parse(content) do |klass, entry|
      case klass
      when :entry
        assert_equal entry[:directive], "asterisk"
        assert_equal entry[:date], "2020-05-15"
      when :posting
        assert_includes ["Liabilities:BankOne", "Income:Cashback"], entry[:account]
      when :meta
        assert_equal entry[:key], "meta"
        assert_equal entry[:value], "\"information\""
      else
        puts "#{klass} #{entry}"
      end
    end
  end

  test "can parse posting without amount" do
    content = <<~EOF
      2020-05-15 * "Bank transfer"
        Liabilities:BankOne               225 TWD ; comment
        Income:Cashback
    EOF

    ParseService.parse(content) do |klass, entry|
      case klass
      when :entry
        assert_equal entry[:directive], "asterisk"
        assert_equal entry[:date], "2020-05-15"
      when :posting
        assert_includes ["Liabilities:BankOne", "Income:Cashback"], entry[:account]
      else
        puts "#{klass} #{entry}"
      end
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
