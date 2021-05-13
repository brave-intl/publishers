require 'test_helper'

class SetPayoutsInProgressJobTest < ActiveJob::TestCase
  test "Sets payout in progress" do
    SetPayoutsInProgressJob.perform_now
    SetPayoutsInProgressJob::CONNECTIONS.each do |connection|
      assert Rails.cache.fetch(SetPayoutsInProgressJob::PAYOUTS_IN_PROGRESS)[connection]
    end
  end
end
