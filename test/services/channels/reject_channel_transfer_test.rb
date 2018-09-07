require "test_helper"
require "webmock/minitest"

class RejectChannelTransferTest < ActiveJob::TestCase
  test "raises if channel is not contested" do
    channel = channels(:fraudulently_verified_site) # uncontested
    assert_raises(Channels::RejectChannelTransfer::ChannelNotContestedError) do
      Channels::RejectChannelTransfer.new(channel: channel).perform
    end
  end

  test "destroys channel, sets resets contest field, sends email" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest the channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    # reject the channel
    Channels::RejectChannelTransfer.new(channel: channel).perform

    assert Channel.where(id: contested_by_channel.id).empty?

    assert_nil channel.contest_timesout_at
    assert_nil channel.contest_token
    assert_nil channel.contested_by_channel_id

    # TODO: test sending of email
  end
end
