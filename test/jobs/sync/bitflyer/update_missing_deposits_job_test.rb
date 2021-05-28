require 'test_helper'
require 'vcr'

class Sync::Bitflyer::UpdateMissingDepositsJobTest < ActiveJob::TestCase
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  test "enqueue no jobs for default scenario" do
    Sync::Bitflyer::UpdateMissingDepositsJob.perform_now
    assert_equal 0, Sync::Bitflyer::UpdateMissingDepositJob.jobs.size
  end

  test "enqueue a job when no deposit_id exists" do
    publisher = publishers(:bitflyer_enabled)
    publisher.channels.first.update_column(:deposit_id, nil)
    Sync::Bitflyer::UpdateMissingDepositsJob.perform_now
    assert_equal 1, Sync::Bitflyer::UpdateMissingDepositJob.jobs.size
  end
end
