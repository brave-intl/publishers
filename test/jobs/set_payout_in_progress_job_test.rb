require 'test_helper'

class SetPayoutInProgressJobTest < ActiveJob::TestCase
  test "Sets payout in progress" do
    Rails.cache.write(SetPayoutInProgressJob::PAYOUT_IN_PROGRESS, false)
    SetPayoutInProgressJob.perform_now(set_to: true)
    assert Rails.cache.fetch(SetPayoutInProgressJob::PAYOUT_IN_PROGRESS)

    Rails.cache.write(SetPayoutInProgressJob::PAYOUT_IN_PROGRESS, true)
    SetPayoutInProgressJob.perform_now(set_to: false)
    refute Rails.cache.fetch(SetPayoutInProgressJob::PAYOUT_IN_PROGRESS)
  end
end
