require "test_helper"
require "webmock/minitest"

class DeletePublisherChannelJobTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "deletes channel for publisher" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:youtube_new)
      channel = channels(:youtube_new)

      stub_request(:delete, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/#{URI.escape(channel.details.channel_identifier)}/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: nil, headers: {})

      DeletePublisherChannelJob.perform_now(channel_id: channel.id)

      # assert something
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "does not throw error if channel has a promo_regsitration" do
    publisher = publishers(:completed)
    sign_in publisher

    # enable the promo
    post promo_registrations_path
    assert_not_nil publisher.channels.first.promo_registration.referral_code
    assert_nothing_raised do
      DeletePublisherChannelJob.perform_now(channel_id: publisher.channels.first.id)
    end
  end

  test "deletes unverifed channel" do
    channel = channels(:default)
    DeletePublisherChannelJob.perform_now(channel_id: channel.id)
    assert Channel.where(id: channel.id).empty?
  end

  test "deletes verified channel" do
    channel = channels(:verified)
    DeletePublisherChannelJob.perform_now(channel_id: channel.id)
    assert Channel.where(id: channel.id).empty?
  end

  test "destroying a channel in contention approvals the contested by channel" do
    channel = channels(:fraudulently_verified_site)
    contested_by_channel = channels(:locked_out_site)
    # contest channel
    Channels::ContestChannel.new(channel: channel, contested_by: contested_by_channel).perform

    # delete the verified channel in contention
    DeletePublisherChannelJob.perform_now(channel_id: channel.id)

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
      DeletePublisherChannelJob.perform_now(channel_id: contested_by_channel.id)
    end

    # ensure the unverified channle is gone
    assert Channel.where(id: contested_by_channel.id).present?

    # ensure the originally verified channel is verified and not contested
    channel.reload
    assert channel.verified?
    assert channel.contest_token
    assert channel.contest_timesout_at
    assert channel.contested_by_channel
  end
end
