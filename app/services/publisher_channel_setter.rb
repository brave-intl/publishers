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
        "owner" => "oauth#google:#{publisher.auth_user_id}",
        "ownerEmail" => publisher.auth_email,
        "ownerName" => publisher.auth_name
      },
      "contactInfo" => {
        "name" => publisher.name,
        "phone" => publisher.phone,
        "email" => publisher.email
      },
      "providers" => [
        {
          "publisher" => "youtube#channel:#{publisher.youtube_channel.id}",
          "show_verification_status" => publisher.show_verification_status
        }
      ]
    }

    # This raises when response is not 2xx.
    response = connection.put do |request|
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
