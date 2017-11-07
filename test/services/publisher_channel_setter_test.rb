require "test_helper"
require "webmock/minitest"

class PublisherChannelSetterTest < ActiveJob::TestCase
  test "when offline does nothing" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = true

      publisher = publishers(:youtube_new)

      assert PublisherChannelSetter.new(publisher: publisher).perform

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "when online sends the channel info" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false

      stub_request(:post, /v1\/owners/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: nil, headers: {})

      publisher = publishers(:youtube_new)

      result = PublisherChannelSetter.new(publisher: publisher).perform
      assert_equal 200, result.status

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end