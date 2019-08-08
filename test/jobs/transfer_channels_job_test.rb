require "test_helper"
require "webmock/minitest"

class TransferChannelsJobTest < ActiveJob::TestCase
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
      assert_enqueued_jobs(4) do
        TransferChannelsJob.perform_now
      end
      
      contested_by_channel.reload
      assert contested_by_channel.verified
    end
  end
end
