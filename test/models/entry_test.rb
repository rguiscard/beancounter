require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "create tags and links" do
    user = users(:one)
    entry = user.entries.create(date: DateTime.current, directive: :txn, arguments: "\"narration\" #2020 ^winter")
    assert_includes entry.tags, "2020"
    assert_includes entry.links, "winter"
  end

  test "update entry cache while posting is created" do
    entry = entries(:one)
    assert entry.bean_cache.blank?

    # create posting cache
    entry.postings.create(account: accounts(:one), arguments: "111 USD")
    refute entry.bean_cache.blank?
  end

  test "update entry cache while posting is update" do
    entry = entries(:one)
    assert entry.bean_cache.blank?

    # create posting cache
    entry.postings.find_each { |x| x.update_attribute(:updated_at, DateTime.current) }
    refute entry.bean_cache.blank?
  end

  test "create bean cache" do
    user = users(:one)
    entry = user.entries.create(date: DateTime.current, directive: :open, arguments: "1234567")
    assert entry.bean_cache.present?
  end
end
