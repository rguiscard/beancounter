require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "beancount is cached when entry is updated" do
    @user.beancount
    old_cached_at = @user.beancount_cached_at
    refute_nil old_cached_at
    @user.entries.last.update_attribute(:arguments, "abc")
    @user.beancount
    assert @user.beancount_cached_at > old_cached_at
  end
end
