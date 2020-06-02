require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "create bean cache" do
    user = users(:one)
    entry = user.entries.create(date: DateTime.current, directive: :open, arguments: "1234567")
    assert entry.bean_cache.present?
  end
end
