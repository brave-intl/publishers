require "test_helper"
require "webmock/minitest"

class SetPublisherJobTest < ActiveJob::TestCase
  def setup
    @prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
    @prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]

    Rails.application.secrets[:host_inspector_offline] = false
    Rails.application.secrets[:api_eyeshade_offline] = false
  end

  def teardown
    Rails.application.secrets[:host_inspector_offline] = @prev_host_inspector_offline
    Rails.application.secrets[:api_eyeshade_offline] = @prev_api_eyeshade_offline
  end

  test "invokes the SiteChannelDomainSetter and saves the channel" do
    details = site_channel_details(:new_site_details)

    stub_request(:get, /v1\/publishers\/identity\?url=http:\/\/new_site\.org/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"new_site.org\"}", headers: {})

    stub_request(:get, "https://new_site.org").
      to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})

    stub_request(:put, /v1\/owners\/#{URI.escape(details.channel.publisher.owner_identifier)}\/verify\/#{details.brave_publisher_id}/).
        with(headers: {'Authorization'=>"Bearer #{Rails.application.secrets[:api_eyeshade_key]}",
                       'Content-Type'=>'application/json'},
             body:
                 <<~BODY
                      {
                        "verificationId": "#{details.brave_publisher_id}"
                      }
        BODY
        ).to_return(status: 200, body: "{\"token\":\"abc123\"}", headers: {})

    SetSiteChannelDomainJob.perform_now(channel_id: details.channel.id)

    details.reload

    assert_equal 'new_site.org', details.brave_publisher_id
    assert details.supports_https
    assert_nil details.brave_publisher_id_unnormalized
    assert_nil details.detected_web_host
    assert details.host_connection_verified
  end
end
