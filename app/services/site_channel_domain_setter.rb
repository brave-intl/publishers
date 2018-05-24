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

    unless channel_details.brave_publisher_id_unnormalized.starts_with?("http")
      channel_details.brave_publisher_id_unnormalized = "http://" + channel_details.brave_publisher_id_unnormalized
    end

    channel_details.brave_publisher_id = Addressable::URI.parse(channel_details.brave_publisher_id_unnormalized).host

    if SiteChannelDetails.joins(:channel).where(brave_publisher_id: channel_details.brave_publisher_id, "channels.verified": true).any?
      channel_details.brave_publisher_id_error_code = :taken
    else
      channel_details.brave_publisher_id_error_code = nil
      channel_details.brave_publisher_id_unnormalized = nil
    end
  rescue SiteChannelDomainNormalizer::DomainExclusionError
    channel_details.brave_publisher_id_error_code = :exclusion_list_error
  rescue Addressable::URI::InvalidURIError
    channel_details.brave_publisher_id_error_code = :invalid_uri
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
end
