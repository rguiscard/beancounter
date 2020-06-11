require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "update account name" do
    account = accounts(:one)
    new_name = "Assets:BoA:Saving"
    account.update(name: new_name)
    account.entries.each do |entry|
      assert entry.arguments.start_with?(new_name)
    end
    account.postings.each do |posting|
      assert posting.to_bean.start_with?(new_name)
      assert posting.bean_cache.start_with?(new_name)
    end
  end

  test "associate entries" do
    account = accounts(:one)

    assert_equal account.entries.count, 0
    assert_equal account.postings.count, 2

    account.associate_entries
    assert_equal account.entries.count, 1
    assert_equal account.postings.count, 2
  end

  test "destroy associated entries" do
    account = accounts(:one)

    assert_difference 'Entry.count', -1 do
      account.destroy
    end
  end
end
