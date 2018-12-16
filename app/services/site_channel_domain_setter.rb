class SiteChannelDomainSetter < BaseService
  attr_reader :channel_details

  def initialize(channel_details:)
    @channel_details = channel_details
  end

  def perform
    normalize_domain if channel_details.brave_publisher_id_unnormalized
    channel_details.inspect_host unless channel_details.brave_publisher_id_error_code
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

    # Throw a Addressable::URI:InvalidURIError if it's an invalid URI
    Addressable::URI.parse("http://#{channel_details.brave_publisher_id}")

    unless DomainName(channel_details.brave_publisher_id).canonical_tld?
      raise DomainExclusionError.new("Non-canonical TLD for #{channel_details.brave_publisher_id}")
    end

    channel_details.brave_publisher_id_error_code = nil
    channel_details.brave_publisher_id_unnormalized = nil
  rescue DomainExclusionError
    channel_details.brave_publisher_id_error_code = :exclusion_list_error
  rescue Addressable::URI::InvalidURIError
    channel_details.brave_publisher_id_error_code = :invalid_uri
  end

  def normalize_from_ruleset(unnormalized_domain)
    # (Albert Wang) Store exceptions here e.g. keybase.pub
    if ["keybase.pub", "badssl.com"].include? PublicSuffix.domain(unnormalized_domain)
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

  class DomainExclusionError < RuntimeError
  end
end
