require "test_helper"
require "webmock/minitest"

class PublisherChannelDeleterTest < ActiveJob::TestCase
  test "deletes unverifed channel" do
    channel = channels(:default)
    PublisherChannelDeleter.new(channel: channel).perform
    assert Channel.where(id: channel.id).empty?
  end

  test "deletes verified channel" do
    channel = channels(:verified)
    PublisherChannelDeleter.new(channel: channel).perform
    assert Channel.where(id: channel.id).empty?
  end

  test "updates eyeshade" do
    # TO DO
  end

  test "updates promo server for promo enabled channels" do
    # TO DO
  end

  test "destroying a channel in contention approvals the contested by channel" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    # delete the verified channel in contention
    PublisherChannelDeleter.new(channel: channel).perform

    # ensure the original channel is gone
    assert Channel.where(id: channel.id).empty?

    # ensure the contested channel is now verified
    contested_by_channel.reload
    assert contested_by_channel.verified?
    refute contested_by_channel.verification_pending?
    assert_nil channel.contesting_channel
  end

  test "destroying a contested_by raises error" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    assert_raises do
      PublisherChannelDeleter.new(channel: contested_by_channel).perform
    end

    # # ensure the unverified channle is gone
    # assert Channel.where(id: contested_by_channel.id).empty?

    # # ensure the originally verified channel is verified and not contested
    # channel.reload
    # assert channel.verified?
    # assert_nil channel.contest_token
    # assert_nil channel.contest_timesout_at
    # assert_nil channel.contested_by_channel
  end
end
