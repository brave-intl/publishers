require 'test_helper'

class SetPayoutInProgressJobTest < ActiveJob::TestCase
  test "Sets payout in progress" do
    Rails.cache.write('payout_in_progress', false)
    SetPayoutInProgressJob.perform_now(set_to: true)
    assert Rails.cache.fetch('payout_in_progress')

    Rails.cache.write('payout_in_progress', true)
    SetPayoutInProgressJob.perform_now(set_to: false)
    refute Rails.cache.fetch('payout_in_progress')
  end
end
