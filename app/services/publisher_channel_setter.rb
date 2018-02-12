# Send publisher and channel info to Eyeshade
class PublisherChannelSetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    verified_channels = publisher.channels.verified.collect do |channel|
      {
          "channelId" => channel.details.channel_identifier,
          "authorizerEmail" => channel.details.authorizerEmail,
          "authorizerName" => channel.details.authorizerName
      }.compact
    end

    payload = {
        "ownerId" => publisher.owner_identifier,
        "contactInfo" => {
            "name" => publisher.name,
            "phone" => publisher.phone_normalized,
            "email" => publisher.email
        }.compact
    }

    payload["channels"] = verified_channels if verified_channels.count > 0

    # This raises when response is not 2xx.
    response = connection.post do |request|
      request.body = payload.to_json
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/v2/owners")
    end

    response
  end

  def perform_offline
    Rails.logger.info("PublisherChannelSetter eyeshade offline; not uploading channel information")
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
