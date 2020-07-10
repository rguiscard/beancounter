require 'test_helper'

class PostingTest < ActiveSupport::TestCase
  test "invalid amount in posting" do
    user = users(:one)
    user.currency = nil
    entry = user.entries.last
    posting = entry.postings.create(account: user.accounts.last, arguments: "123")

    assert posting.invalid?
  end

  test "valid amount in posting" do
    user = users(:one)
    entry = user.entries.last
    posting = entry.postings.create(account: user.accounts.last, arguments: "123 USD")

    assert posting.valid?
  end

  test "create bean cache" do
    user = users(:one)
    entry = user.entries.last
    posting = entry.postings.create(account: user.accounts.last, arguments: "123 USD")
    assert posting.bean_cache.present?
  end
end
