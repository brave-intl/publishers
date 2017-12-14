class PublisherDomainSetter < BaseService
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    normalize_domain if @publisher.brave_publisher_id_unnormalized
    inspect_host unless @publisher.brave_publisher_id_error_code
  end

  private

  def normalize_domain
    require "faraday"

    brave_publisher_id = PublisherDomainNormalizer.new(domain: @publisher.brave_publisher_id_unnormalized).perform

    if Publisher.where(brave_publisher_id: brave_publisher_id, verified: true).any?
      @publisher.brave_publisher_id_error_code = :taken
    else
      @publisher.brave_publisher_id = brave_publisher_id
      @publisher.brave_publisher_id_error_code = nil
      @publisher.brave_publisher_id_unnormalized = nil
    end

  rescue PublisherDomainNormalizer::DomainExclusionError
    @publisher.brave_publisher_id_error_code = :exclusion_list_error
  rescue Faraday::Error
    @publisher.brave_publisher_id_error_code = :api_error_cant_normalize
  rescue URI::InvalidURIError
    @publisher.brave_publisher_id_error_code = :invalid_uri
  end

  def inspect_host
    return unless @publisher.brave_publisher_id

    result = PublisherHostInspector.new(brave_publisher_id: @publisher.brave_publisher_id).perform
    if result[:host_connection_verified]
      @publisher.supports_https = result[:https]
      @publisher.detected_web_host = result[:web_host]
      @publisher.host_connection_verified = true
    else
      @publisher.supports_https = false
      @publisher.detected_web_host = nil
      @publisher.host_connection_verified = false
    end
  end
end
