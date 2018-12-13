require 'test_helper'

class ChannelsJsonBuilderTest < ActiveSupport::TestCase

  SITE_BANNER_INDEX = 3

  def get_channel_from_json(channels, channel_id)
    channels.each do |channel_info|
      return channel_info if channel_info.first == channel_id
    end

    nil
  end

  test "returns JSON" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    assert channels
  end

  test "number of channels returned is at least as large as number of verified channels" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    assert channels.count >= Channel.verified.count
  end

  test "number of channels returned is at least as large as number of excluded channels " do
    require "publishers/excluded_channels"
    @excluded_channel_ids = Publishers::ExcludedChannels.brave_publisher_id_list
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    assert channels.count >= @excluded_channel_ids.count
  end

  test "verified channel that is not excluded is returned and marked correctly" do
    verified_channel = channels(:completed) # not excluded
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    channel = get_channel_from_json(channels, verified_channel.details.channel_identifier)

    # ensure channel is in the JSON channels response
    assert channel

    # ensure channel is marked as verified
    assert_equal channel.second, true

    # ensure channel is marked as not excluded
    assert_equal channel.third, false
  end

  test "unverified channel that is not excluded is not returned" do
    unverified_channel = channels(:default) # unverfied, not excluded
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    channel = get_channel_from_json(channels, unverified_channel.details.channel_identifier)

    # ensure channel is not returned in the response
    refute channel
  end

  test "verified channel that is excluded is returned and marked correctly" do
    verified_excluded_channel = channels(:verified_exclude)
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    channel = get_channel_from_json(channels, verified_excluded_channel.details.channel_identifier)

    # ensure channel is in the JSON channels response
    assert channel

    # ensure channel is marked as verified
    assert_equal channel.second, true

    # ensure channel is marked as excluded
    assert_equal channel.third, true
  end

  test "unverified channel that is excluded is returned and marked correctly" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    unverified_excluded_channel_id = "456.gov"
    channel = get_channel_from_json(channels, unverified_excluded_channel_id)

    # ensure channel is in the JSON channels response
    assert channel

    # ensure channel is marked as verified
    assert_equal channel.second, false

    # ensure channel is marked as not verified
    assert_equal channel.third, true
  end

  test "returned channels only appear once" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)
    returned_channel_ids = []
    channels.each do |channel|
      if returned_channel_ids.include?(channel.first)
        assert false
      else
        returned_channel_ids.push(channel.first)
      end
    end
  end

  test "returns default site_banner if default_site_banner_mode is true" do
    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)

    default_site_banner = site_banners(:verified_default_banner)
    verified_channel = channels(:verified)
    channel = get_channel_from_json(channels, verified_channel.details.channel_identifier)

    assert_equal channel[SITE_BANNER_INDEX]["title"], default_site_banner[:title]
  end

  test "returns channel site_banner if default_site_banner_mode is false" do
    verified_channel = channels(:verified)
    channel_site_banner = site_banners(:verified_channel_banner)

    channel_site_banner.update(channel_id: verified_channel.id)
    verified_channel.publisher.update(default_site_banner_mode: false)

    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)

    verified_channel = channels(:verified)
    channel = get_channel_from_json(channels, verified_channel.details.channel_identifier)
    assert_equal channel[SITE_BANNER_INDEX]["title"], channel_site_banner[:title]
  end

  test "returns {} for site_banner if err" do
    verified_channel = channels(:verified)
    verified_channel.publisher.update(default_site_banner_mode: false)
    # Simulated error
    verified_channel.site_banner = nil

    channels = JSON.parse(JsonBuilders::ChannelsJsonBuilder.new.build)

    channel = get_channel_from_json(channels, verified_channel.details.channel_identifier)
    assert_equal channel[SITE_BANNER_INDEX], {}
  end
end
