require "test_helper"
require "webmock/minitest"

class ApproveChannelTransferTest < ActiveJob::TestCase
  test "verifies contested_by and destroys original channel, sends email" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)

    # contest the channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform    

    # approve the channel
    Channels::ApproveChannelTransfer.new(channel: channel).perform
    contested_by_channel.reload

    # ensure contested_by channel now is verified
    assert contested_by_channel.verified?
    refute contested_by_channel.verification_pending

    # ensure original channel is destroyed
    assert Channel.where(id: channel.id).empty?
  end

  test "raises if channel is not being contested" do
    channel = channels(:fraudulently_verified_site)

    assert_raises do
      Channels::ApproveChannelTransfer.new(channel: channel).perform
    end
  end
end
