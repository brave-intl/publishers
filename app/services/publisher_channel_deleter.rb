class PublisherChannelDeleter < BaseApiClient
  attr_reader :publisher
  attr_reader :channel_identifier

  def initialize(publisher:, channel_identifier:)
    @publisher = publisher
    @channel_identifier = channel_identifier
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    # This raises when response is not 2xx.
    response = connection.delete do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/v1/owners/#{URI.escape(@publisher.owner_identifier)}/#{URI.escape(channel_identifier)}")
    end

    response
  end

  def perform_offline
    Rails.logger.info("PublisherChannelDeleter eyeshade offline; not deleting channel")
    true
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
