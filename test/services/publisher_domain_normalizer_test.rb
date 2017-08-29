require "test_helper"
require "webmock/minitest"

class PublisherDomainNormalizerTest < ActiveJob::TestCase
  test "when offline normalizes the domain" do
    prev_api_ledger_offline = Rails.application.secrets[:api_ledger_offline]
    Rails.application.secrets[:api_ledger_offline] = true

    assert_equal "example.com", PublisherDomainNormalizer.new(domain: "https://example.com").perform
    assert_equal "example2.com", PublisherDomainNormalizer.new(domain: "example2.com").perform

    Rails.application.secrets[:api_ledger_offline] = prev_api_ledger_offline
  end

  test "when online normalizes the domain" do
    prev_api_ledger_offline = Rails.application.secrets[:api_ledger_offline]
    Rails.application.secrets[:api_ledger_offline] = false

    stub_request(:get, /v2\/publisher\/identity\?url=http:\/\/example\.com/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"example.com\"}", headers: {})

    stub_request(:get, /v2\/publisher\/identity\?url=http:\/\/example2\.com/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example2.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\",\"publisher\":\"example2.com\"}", headers: {})

    assert_equal "example.com", PublisherDomainNormalizer.new(domain: "https://example.com").perform
    assert_equal "example2.com", PublisherDomainNormalizer.new(domain: "example2.com").perform

    Rails.application.secrets[:api_ledger_offline] = prev_api_ledger_offline
  end

  test "raises exception with invalid url with protocol" do
    assert_raises(URI::InvalidURIError) do
      PublisherDomainNormalizer.new(domain: "https://bad url.com").perform
    end
  end

  test "raises exception with invalid url without protocol" do
    assert_raises(URI::InvalidURIError) do
      PublisherDomainNormalizer.new(domain: "bad url.com").perform
    end
  end

  test "when online handles normalization failures by raising DomainExclusionError" do
    prev_api_ledger_offline = Rails.application.secrets[:api_ledger_offline]
    Rails.application.secrets[:api_ledger_offline] = false

    stub_request(:get, /v2\/publisher\/identity\?url=http:\/\/example3.com/).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: "{\"protocol\":\"http:\",\"slashes\":true,\"auth\":null,\"host\":\"example2.com\",\"port\":null,\"hostname\":\"foo-bar.com\",\"hash\":null,\"search\":\"\",\"query\":{},\"pathname\":\"/\",\"path\":\"/\",\"href\":\"http://foo-bar.com/\",\"TLD\":\"com\",\"URL\":\"http://foo-bar.com\",\"SLD\":\"foo-bar.com\",\"RLD\":\"\",\"QLD\":\"\"}", headers: {})

    assert_raises(PublisherDomainNormalizer::DomainExclusionError) do
      PublisherDomainNormalizer.new(domain: "https://example3.com").perform
    end

    Rails.application.secrets[:api_ledger_offline] = prev_api_ledger_offline
  end
end