# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"
require "dnsruby"

class SiteChannelVerifierTest < ActiveSupport::TestCase
  VERIFICATION_TOKEN = "6d660f14752f460b59dc62907bfe3ae1cb4727ae0645de74493d99bcf63ddb94"

  def stub_verification_public_file(channel, body: nil, status: 200)
    url = "https://#{channel.details.brave_publisher_id}/.well-known/brave-payments-verification.txt"
    headers = {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Host' => channel.details.brave_publisher_id,
      'User-Agent' => 'Ruby'
    }
    body ||= SiteChannelVerificationFileGenerator.new(site_channel: channel).generate_file_content
    stub_request(:get, url).
      with(headers: headers).
      to_return(status: status, body: body, headers: {})
  end

  def assert_verification(channel)
    refute channel.verified?
    verifier = SiteChannelVerifier.new(channel: channel)
    verifier.perform
    channel.reload
    assert channel.verified?
  end

  def refute_verification(channel)
    refute channel.verified?
    verifier = SiteChannelVerifier.new(channel: channel)
    verifier.perform
    channel.reload
    refute channel.verified?
    assert channel.verification_failed?
  end

  test "file method verifies with public file at .well-known URL" do
    c = channels(:to_verify_file)
    stub_verification_public_file(c)
    assert_verification(c)
  end

  test "file method verifies with abridged public file with correct token at .well-known URL" do
    c = channels(:to_verify_file)
    stub_verification_public_file(c, body: c.details.verification_token)
    assert_verification(c)
  end

  test "file method fails with 404 Not found at .well-known URL" do
    c = channels(:to_verify_file)
    stub_verification_public_file(c, body: "", status: 404)
    refute_verification(c)
  end

  test "file method fails with junk public file with correct token at .well-known URL" do
    c = channels(:to_verify_file)
    stub_verification_public_file(c, body: "420")
    refute_verification(c)
  end

  test "github method verifies with public file at .well-known URL" do
    c = channels(:to_verify_github)
    stub_verification_public_file(c)
    assert_verification(c)
  end

  test "wordpress method verifies with public file at .well-known URL" do
    c = channels(:to_verify_wordpress)
    stub_verification_public_file(c)
    assert_verification(c)
  end

  test "DNS method verifies domain TXT entry" do
    dns_response = YAML::load_file(Rails.root.join("test/stubs/dnsruby/site_verification_txt.yml"))
    Dnsruby::Resolver.any_instance.stubs(:query).returns(dns_response)
    c = channels(:to_verify_dns)
    assert_verification(c)
  end

  test "DNS method fails domain with abridged TXT entry" do
    dns_response = YAML::load_file(Rails.root.join("test/stubs/dnsruby/site_verification_txt_abridged.yml"))
    Dnsruby::Resolver.any_instance.stubs(:query).returns(dns_response)
    c = channels(:to_verify_dns)
    refute_verification(c)
  end

  test "DNS method fails for domain with different TXT entry" do
    dns_response = YAML::load_file(Rails.root.join("test/stubs/dnsruby/site_verification_txt_other.yml"))
    Dnsruby::Resolver.any_instance.stubs(:query).returns(dns_response)
    c = channels(:to_verify_dns)
    refute_verification(c)
  end

  test "DNS method fails for domain without any TXT entries" do
    dns_response = YAML::load_file(Rails.root.join("test/stubs/dnsruby/without_txt.yml"))
    Dnsruby::Resolver.any_instance.stubs(:query).returns(dns_response)
    c = channels(:to_verify_dns)
    refute_verification(c)
  end

  test "DNS method fails for domain with unrelated TXT entries" do
    dns_response = YAML::load_file(Rails.root.join("test/stubs/dnsruby/unrelated_txt.yml"))
    Dnsruby::Resolver.any_instance.stubs(:query).returns(dns_response)
    c = channels(:to_verify_dns)
    refute_verification(c)
  end

  test "DNS method fails for nonexistent (NX) domain" do
    Dnsruby::Resolver.any_instance.stubs(:query).raises(Dnsruby::NXDomain.new)
    c = channels(:to_verify_dns)
    refute_verification(c)
  end

  test "support queue method fails" do
    c = channels(:to_verify_support)
    refute_verification(c)
  end

  test "fails and raises if channel is not a site channel" do
    c = channels(:youtube_initial)
    assert_raise SiteChannelVerifier::UnsupportedChannelType do
      verifier = SiteChannelVerifier.new(channel: c)
      verifier.perform
    end
  end

  test "restricted site channels do not verify" do
    c = channels(:to_verify_restricted)
    stub_verification_public_file(c)
    refute c.verified?
    verifier = SiteChannelVerifier.new(channel: c)
    verifier.perform
    c.reload
    refute c.verified?
  end

  test "restricted site channels await admin approval" do
    c = channels(:to_verify_restricted)
    stub_verification_public_file(c)
    refute c.verification_awaiting_admin_approval?
    verifier = SiteChannelVerifier.new(channel: c)
    verifier.perform
    c.reload
    assert c.verification_awaiting_admin_approval?
  end

  test "restricted site channels verify with admin approval" do
    c = channels(:to_verify_restricted)
    stub_verification_public_file(c)
    refute c.verification_awaiting_admin_approval?
    verifier = SiteChannelVerifier.new(has_admin_approval: true, channel: c)
    verifier.perform
    c.reload
    assert c.verified?
  end
end