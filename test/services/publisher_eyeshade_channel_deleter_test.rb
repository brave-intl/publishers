require "test_helper"
require "webmock/minitest"

class PublisherEyeshadeChannelDeleterTest < ActiveJob::TestCase
  test "when offline does nothing" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:youtube_new)
      channel = channels(:youtube_new)

      assert PublisherEyeshadeChannelDeleter.new(publisher: publisher, channel_identifier: channel.details.channel_identifier).perform

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "when online deletes the channel" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      publisher = publishers(:youtube_new)
      channel = channels(:youtube_new)
      channel_identifier = channel.details.channel_identifier

      stub_request(:delete, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/#{URI.escape(channel_identifier)}/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: nil, headers: {})

      result = PublisherEyeshadeChannelDeleter.new(publisher: publisher, channel_identifier: channel_identifier).perform
      assert_equal 200, result.status

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
