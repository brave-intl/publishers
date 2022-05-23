# typed: false
require "test_helper"
require "jobs/sidekiq_test_case"
require "vcr"

class Sync::Bitflyer::UpdateMissingDepositsJobTest < SidekiqTestCase
  include MockOauth2Responses
  include MockBitflyerResponses

  test "enqueue no jobs for default scenario" do
    Sync::Bitflyer::UpdateMissingDepositsJob.new.perform
    assert_equal 0, Sync::Bitflyer::UpdateMissingDepositJob.jobs.size
  end

  test "enqueue a job when no deposit_id exists" do
    publisher = publishers(:bitflyer_pub)
    publisher.channels.first.update_column(:deposit_id, nil)
    Sync::Bitflyer::UpdateMissingDepositsJob.new.perform
    assert_equal 1, Sync::Bitflyer::UpdateMissingDepositJob.jobs.size
  end

  describe "#perform" do
    let(:publisher) { publishers(:bitflyer_pub) }
    let(:channel) { publisher.channels.first }
    let(:connection) { publisher.bitflyer_connection }

    before do
      Channel.using_active_bitflyer_connection.update_all(deposit_id: nil)
      assert Channel.where.not(deposit_id: nil).count == 0
      mock_refresh_token_success(connection.class.oauth2_config.token_url)
      mock_create_deposit_id_success
    end

    it "should update all missing deposit_ids" do
      Sync::Bitflyer::UpdateMissingDepositsJob.new.perform(async: false)
      assert_equal 0, Channel.using_active_bitflyer_connection.where(deposit_id: nil).count
    end
  end
end
