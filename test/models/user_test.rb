require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "beancount is cached when entry is updated" do
    @user.beancount
    old_updated_at = @user.beancount_updated_at
    refute_nil old_updated_at
    @user.entries.last.update_attribute(:arguments, "abc")
    @user.beancount
    assert @user.beancount_updated_at > old_updated_at
  end
end
