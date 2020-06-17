require "test_helper"
require "webmock/minitest"

class Channels::TransferChannelsJobTest < ActiveJob::TestCase
  before do
    # Mock out the creation of cards
    stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
    stub_request(:post, /cards/).to_return(body: { id: "fb25048b-79df-4e64-9c4e-def07c8f5c04" }.to_json)
    stub_request(:get, /address/).to_return(body: [{ formats: [{ format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1" }], type: "anonymous" }].to_json)
  end

  test "does not approve channels unless timeout period has passed" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert_enqueued_jobs(0) do
      Channels::TransferChannelsJob.perform_now
    end

    contested_by_channel.reload
    refute contested_by_channel.verified
  end

  test "approves channels that have waited the timeout period" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform
    clear_enqueued_jobs
    clear_performed_jobs

    travel(Channel::CONTEST_TIMEOUT + 1.minute) do
      assert_enqueued_jobs 0
      Channels::TransferChannelsJob.perform_now

      assert_enqueued_jobs 1
      assert_performed_jobs 0

      perform_enqueued_jobs

      # There are 5 jobs enqueued (4 emails and a slack message) when a channel completes transfer
      # + 2 for the actual jobs that were completed, so 7 overall
      assert_performed_jobs 7

      contested_by_channel.reload
      assert contested_by_channel.verified
    end
  end
end
