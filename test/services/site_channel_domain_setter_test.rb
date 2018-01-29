require "test_helper"
require "webmock/minitest"

class SiteChannelDomainSetterTest < ActiveJob::TestCase
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

  test "normalizes and inspects the domain" do
    stub_request(:get, /v1\/publishers\/identity\?url=https:\/\/example\.com/).
      to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"example.com\"}", headers: {})

    stub_request(:get, "https://example.com").
      to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})

    channel_details = SiteChannelDetails.new
    channel_details.brave_publisher_id_unnormalized = "https://example.com"

    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    assert_equal 'example.com', channel_details.brave_publisher_id
    assert channel_details.supports_https
    assert_nil channel_details.detected_web_host
    assert channel_details.host_connection_verified
  end

  test "skips normalization if it's unnecessary and just inspects the domain" do
    stub_request(:get, "https://example.com").
      to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})

    channel_details = SiteChannelDetails.new
    channel_details.brave_publisher_id = "example.com"

    refute channel_details.supports_https
    assert_nil channel_details.detected_web_host
    refute channel_details.host_connection_verified

    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    assert channel_details.supports_https
    assert_nil channel_details.detected_web_host
    assert channel_details.host_connection_verified
  end

  test "normalization can succeed and inspection can fail if connection to site fails when https and http fail" do
    stub_request(:get, /v1\/publishers\/identity\?url=https:\/\/mywordpressisdown\.com/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"mywordpressisdown.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"mywordpressisdown.com\"}", headers: {})

    stub_request(:get, "https://mywordpressisdown.com").
      to_raise(Errno::ECONNREFUSED.new)
    stub_request(:get, "https://www.mywordpressisdown.com").
      to_raise(Errno::ECONNREFUSED.new)

    stub_request(:get, "http://mywordpressisdown.com").
      to_raise(Errno::ECONNREFUSED.new)

    channel_details = SiteChannelDetails.new
    channel_details.brave_publisher_id_unnormalized = "mywordpressisdown.com"

    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    refute channel_details.supports_https
    assert_nil channel_details.detected_web_host
    refute channel_details.host_connection_verified
  end

  test "raises exception with invalid url with protocol" do
    channel_details = SiteChannelDetails.new
    channel_details.brave_publisher_id_unnormalized = "https://bad url.com"
    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    assert_equal 'invalid_uri', channel_details.brave_publisher_id_error_code
  end

  test "raises exception when domain is already taken by a verified publisher" do
    stub_request(:get, /v1\/publishers\/identity\?url=https:\/\/verified\.org/).
      with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"verified.org\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"verified.org\"}", headers: {})

    channel_details = SiteChannelDetails.new

    existing_channel = channels(:verified)
    channel_details.brave_publisher_id_unnormalized = existing_channel.details.brave_publisher_id
    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    assert_equal 'taken', channel_details.brave_publisher_id_error_code
  end

  test "when online handles normalization failures by raising DomainExclusionError" do
    stub_request(:get, /v1\/publishers\/identity\?url=https:\/\/example3.com/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example2.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\"}", headers: {})

    channel_details = SiteChannelDetails.new
    channel_details.brave_publisher_id_unnormalized = "https://example3.com"

    SiteChannelDomainSetter.new(channel_details: channel_details).perform

    assert_equal 'exclusion_list_error', channel_details.brave_publisher_id_error_code
  end
end