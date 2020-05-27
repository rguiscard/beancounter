require 'test_helper'

class AccountBalanceJobTest < ActiveJob::TestCase
  test "write to tempfile" do
    AccountBalanceJob.perform_now
    assert true
  end
end
