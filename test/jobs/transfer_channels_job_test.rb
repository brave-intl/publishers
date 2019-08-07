require "test_helper"
require "webmock/minitest"

class TransferChannelsJobTest < ActiveJob::TestCase
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
      TransferChannelsJob.perform_now
    end

    contested_by_channel.reload
    refute contested_by_channel.verified
  end

  test "approves channels that have waited the timeout period" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    travel (Channel::CONTEST_TIMEOUT + 1.minute) do
      assert_enqueued_jobs(6) do
        TransferChannelsJob.perform_now
      end

      contested_by_channel.reload
      assert contested_by_channel.verified
    end
  end
end
