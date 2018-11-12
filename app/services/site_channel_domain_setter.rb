class SiteChannelDomainSetter < BaseService
  attr_reader :channel_details

  def initialize(channel_details:)
    @channel_details = channel_details
  end

  def perform
    normalize_domain if channel_details.brave_publisher_id_unnormalized
    inspect_host #unless channel_details.brave_publisher_id_error_code
  end

  private

  def normalize_domain
    require 'addressable'
    require 'domain_name'

    remove_protocol_and_suffix(channel_details)

=begin
    May 24, 2018
    (Albert Wang): We've been supporting subdomains, so we need to use the PublicSuffix list

    E.g.
      > PublicSuffix.domain("m.reddit.com")
     => "reddit.com"

      > PublicSuffix.domain("helloworld.github.io")
     => "helloworld.github.io"

      > PublicSuffix.domain("hello.blogspot.com")
     => "hello.blogspot.com"
=end
    channel_details.brave_publisher_id = normalize_from_ruleset(channel_details.brave_publisher_id_unnormalized)
    unless DomainName(channel_details.brave_publisher_id).canonical_tld?
      raise DomainExclusionError.new("Non-canonical TLD for #{channel_details.brave_publisher_id}")
    end

    # Throw a Addressable::URI:InvalidURIError if it's an invalid URI
    Addressable::URI.parse("http://" + channel_details.brave_publisher_id)

    channel_details.brave_publisher_id_error_code = nil
    channel_details.brave_publisher_id_unnormalized = nil
  rescue DomainExclusionError
    channel_details.brave_publisher_id_error_code = :exclusion_list_error
  rescue Addressable::URI::InvalidURIError
    channel_details.brave_publisher_id_error_code = :invalid_uri
  end

  def normalize_from_ruleset(unnormalized_domain)
    # (Albert Wang) Store exceptions here e.g. keybase.pub
    if PublicSuffix.domain(unnormalized_domain) == "keybase.pub"
      Addressable::URI.parse("http://#{unnormalized_domain}").normalize.host
    else
      PublicSuffix.domain(unnormalized_domain)
    end
  end

  def remove_protocol_and_suffix(channel_details)
    unless channel_details.brave_publisher_id_unnormalized.starts_with?(*["http://", "https://"])
      channel_details.brave_publisher_id_unnormalized.prepend("http://")
    end
    channel_details.brave_publisher_id_unnormalized = Addressable::URI.parse(channel_details.brave_publisher_id_unnormalized).normalize.host
  end

  def inspect_host
    return unless channel_details.brave_publisher_id
    # channel_details.brave_publisher_id  = 'expired.badssl.com/' 👍
    # channel_details.brave_publisher_id  = "wrong.host.badssl.com" 👍
    # channel_details.brave_publisher_id  = "self-signed.badssl.com" 👍
    # channel_details.brave_publisher_id  = "untrusted-root.badssl.com" 👍
    # channel_details.brave_publisher_id  = "sha1-intermediate.badssl.com" 🚫
    # channel_details.brave_publisher_id  = "rc4.badssl.com" 🚫
    # channel_details.brave_publisher_id  = "rc4-md5.badssl.com" 👍
    # channel_details.brave_publisher_id  = "dh480.badssl.com" 👍
    # channel_details.brave_publisher_id  = "dh512.badssl.com" 👍
    # channel_details.brave_publisher_id  = "dh1024.badssl.com" 🚫
    # channel_details.brave_publisher_id  = "superfish.badssl.com" 👍
    # channel_details.brave_publisher_id  = "edellroot.badssl.com" 👍
    # channel_details.brave_publisher_id  = "dsdtestprovider.badssl.com"
    # channel_details.brave_publisher_id  = "preact-cli.badssl.com"
    # channel_details.brave_publisher_id  = "webpack-dev-server.badssl.com"
    # channel_details.brave_publisher_id  = "null.badssl.com"
    # channel_details.brave_publisher_id  = "revoked.badssl.com"
    # channel_details.brave_publisher_id  = "invalid-expected-sct.badssl.com"
    [
      "tls-v1-2.badssl.com:1012",
      "sha256.badssl.com",
      "sha384.badssl.com",
      "expired.badssl.com",
      "wrong.host.badssl.com",
      "self-signed.badssl.com",
      "untrusted-root.badssl.com",
      "sha1-intermediate.badssl.com",
      "rc4.badssl.com",
      "rc4-md5.badssl.com",
      "dh480.badssl.com",
      "dh512.badssl.com",
      "dh1024.badssl.com",
      "superfish.badssl.com",
      "edellroot.badssl.com",
      "dsdtestprovider.badssl.com",
      "preact-cli.badssl.com",
      "webpack-dev-server.badssl.com",
      "null.badssl.com",
      "revoked.badssl.com",
      "invalid-expected-sct.badssl.com",
      "sha512.badssl.com",
      "rsa2048.badssl.com",
      "ecc256.badssl.com",
      "ecc384.badssl.com",
    ].each do |x|
      result = SiteChannelHostInspector.new(brave_publisher_id: x).perform

      if result[:host_connection_verified]
        Rails.logger.warn("#{x} 🚫")
      else
        Rails.logger.warn("#{x} 👍")
      end

    end

    binding.pry

    result = SiteChannelHostInspector.new(brave_publisher_id: channel_details.brave_publisher_id).perform
    if result[:host_connection_verified]
      channel_details.supports_https = result[:https]
      channel_details.detected_web_host = result[:web_host]
      channel_details.host_connection_verified = true
    else
      channel_details.supports_https = false
      channel_details.detected_web_host = nil
      channel_details.host_connection_verified = false
    end
  end

  class DomainExclusionError < RuntimeError
  end
end
