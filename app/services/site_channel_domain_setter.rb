class SiteChannelDomainSetter < BaseService
  attr_reader :channel

  def initialize(channel:)
    @channel = channel
  end

  def perform
    normalize_domain if channel.details.brave_publisher_id_unnormalized
    inspect_host unless channel.details.brave_publisher_id_error_code
  end

  private

  def normalize_domain
    require "faraday"

    brave_publisher_id = SiteChannelDomainNormalizer.new(domain: channel.details.brave_publisher_id_unnormalized).perform

    if SiteChannelDetails.joins(:channel).where(brave_publisher_id: brave_publisher_id, "channels.verified": true).any?
      channel.details.brave_publisher_id_error_code = :taken
    else
      channel.details.brave_publisher_id = brave_publisher_id
      channel.details.brave_publisher_id_error_code = nil
      channel.details.brave_publisher_id_unnormalized = nil
    end

  rescue SiteChannelDomainNormalizer::DomainExclusionError
    channel.details.brave_publisher_id_error_code = :exclusion_list_error
  rescue Faraday::Error
    channel.details.brave_publisher_id_error_code = :api_error_cant_normalize
  rescue URI::InvalidURIError
    channel.details.brave_publisher_id_error_code = :invalid_uri
  end

  def inspect_host
    return unless channel.details.brave_publisher_id

    result = SiteChannelHostInspector.new(brave_publisher_id: channel.details.brave_publisher_id).perform
    if result[:host_connection_verified]
      channel.details.supports_https = result[:https]
      channel.details.detected_web_host = result[:web_host]
      channel.details.host_connection_verified = true
    else
      channel.details.supports_https = false
      channel.details.detected_web_host = nil
      channel.details.host_connection_verified = false
    end
  end
end
