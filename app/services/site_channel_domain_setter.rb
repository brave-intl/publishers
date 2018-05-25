class SiteChannelDomainSetter < BaseService
  attr_reader :channel_details

  def initialize(channel_details:)
    @channel_details = channel_details
  end

  def perform
    normalize_domain if channel_details.brave_publisher_id_unnormalized
    inspect_host unless channel_details.brave_publisher_id_error_code
  end

  private

  def normalize_domain
    require 'addressable'
    require 'domain_name'

    remove_protocol(channel_details)

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
    channel_details.brave_publisher_id = PublicSuffix.domain(channel_details.brave_publisher_id_unnormalized)

    unless DomainName(channel_details.brave_publisher_id).canonical_tld?
      raise DomainExclusionError.new("Non-canonical TLD for #{url}")
    end

    # Throw a Addressable::URI:InvalidURIError if it's an invalid URI
    Addressable::URI.parse("http://" + channel_details.brave_publisher_id)

    if SiteChannelDetails.joins(:channel).where(brave_publisher_id: channel_details.brave_publisher_id, "channels.verified": true).any?
      channel_details.brave_publisher_id_error_code = :taken
    else
      channel_details.brave_publisher_id_error_code = nil
      channel_details.brave_publisher_id_unnormalized = nil
    end
  rescue DomainExclusionError
    channel_details.brave_publisher_id_error_code = :exclusion_list_error
  rescue Addressable::URI::InvalidURIError
    channel_details.brave_publisher_id_error_code = :invalid_uri
  end

  def remove_protocol(channel_details)
    ["http://", "https://"].each do |protocol|
      if channel_details.brave_publisher_id_unnormalized.starts_with?(protocol)
        channel_details.brave_publisher_id_unnormalized = channel_details.brave_publisher_id_unnormalized.remove(protocol)
        break
      end
    end
  end

  def inspect_host
    return unless channel_details.brave_publisher_id

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
