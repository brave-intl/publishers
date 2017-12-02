require "test_helper"
require "webmock/minitest"

class SetPublisherJobTest < ActiveJob::TestCase
  def setup
    @prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
    @prev_api_ledger_offline = Rails.application.secrets[:api_ledger_offline]

    Rails.application.secrets[:host_inspector_offline] = false
    Rails.application.secrets[:api_ledger_offline] = false
  end

  def teardown
    Rails.application.secrets[:host_inspector_offline] = @prev_host_inspector_offline
    Rails.application.secrets[:api_ledger_offline] = @prev_api_ledger_offline
  end

  test "invokes the PublisherDomainSetter and saves the publisher" do
    stub_request(:get, /v2\/publisher\/identity\?url=http:\/\/example\.com/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"example.com\"}", headers: {})

    stub_request(:get, "https://example.com").
      to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})

    publisher = publishers(:default)
    publisher.brave_publisher_id = nil
    publisher.brave_publisher_id_unnormalized = "https://example.com"
    publisher.save!

    SetPublisherDomainJob.perform_now(publisher_id: publisher.id)

    publisher.reload
    assert_equal 'example.com', publisher.brave_publisher_id
    assert publisher.supports_https
    assert_nil publisher.detected_web_host
    assert publisher.host_connection_verified
  end
end
