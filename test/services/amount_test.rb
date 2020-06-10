require 'test_helper'

class AmountTest < ActiveSupport::TestCase
  test "can parse simple amount" do
    s = "10 USD"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
  end

  test "can parse simple amount with comment" do
    s = "10 USD ; This is a comment"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
  end

  test "can parse amount with cost" do
    s = "10 USD { 1.1 CAD }"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD }"
  end

  test "can parse amount with cost and comment" do
    s = "10 USD { 1.1 CAD }; This is a comment"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD }"
  end

  test "can parse amount with price" do
    s = "10 USD @@ 11 CAD"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.price, "@@ 11 CAD"
  end

  test "can parse amount with price and comment" do
    s = "10 USD @@ 11 CAD; This is a comment"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.price, "@@ 11 CAD"
  end

  test "can parse amount with unit price" do
    s = "10 USD @ 1.1 CAD"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.unit_price, "@ 1.1 CAD"
  end

  test "can parse amount with unit price and comment" do
    s = "10 USD @ 1.1 CAD; This is a comment"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.unit_price, "@ 1.1 CAD"
  end

  test "can parse amount with cost and unit price" do
    s = "10 USD { 1.1 CAD }@ 1.1 CAD"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD }"
    assert_equal amount.unit_price, "@ 1.1 CAD"
  end

  test "can parse amount with cost, unit price and comment" do
    s = "10 USD { 1.1 CAD} @ 1.1 CAD; This is a comment"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD}"
    assert_equal amount.unit_price, "@ 1.1 CAD"
  end

  test "can parse amount with cost and price" do
    s = "10 USD { 1.1 CAD }@@ 11 CAD"
    amount = ::Amount.new(s)
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD }"
    assert_equal amount.price, "@@ 11 CAD"
  end

  test "can parse amount with cost, price and comment" do
    s = "10 USD { 1.1 CAD} @@ 11 CAD; This is a comment"
    amount = ::Amount.new(s)
    refute amount.blank?
    assert_equal amount.number, "10"
    assert_equal amount.currency, "USD"
    assert_equal amount.cost, "{ 1.1 CAD}"
    assert_equal amount.price, "@@ 11 CAD"
  end

  test "can be blank" do
    s = "{ 1.1 CAD} @@ 11 CAD; This is a comment"
    amount = ::Amount.new(s)
    puts amount.number
    puts amount.currency
    assert amount.blank?
  end
end
