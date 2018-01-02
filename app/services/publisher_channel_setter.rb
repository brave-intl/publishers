# Ask Eyeshade to assign youtube channels to a Publisher.
class PublisherChannelSetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    payload = {
      "authorizer" => {
        "owner" => publisher.owner_identifier,
        "ownerEmail" => publisher.auth_email,
        "ownerName" => publisher.auth_name
      }.compact,
      "contactInfo" => {
        "name" => publisher.name,
        "phone" => publisher.phone_normalized,
        "email" => publisher.email
      }.compact,
      "providers" => [
        {
          "publisher" => publisher.youtube_channel.channel_identifier,
          "show_verification_status" => publisher.show_verification_status?
        }
      ]
    }

    # This raises when response is not 2xx.
    response = connection.post do |request|
      request.body = payload.to_json
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"
      request.url("/v1/owners")
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
