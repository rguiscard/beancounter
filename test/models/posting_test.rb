require 'test_helper'

class PostingTest < ActiveSupport::TestCase
  test "create bean cache" do
    user = users(:one)
    entry = user.entries.last
    posting = entry.postings.create(account: user.accounts.last, arguments: "1234567")
    assert posting.bean_cache.present?
  end
end
