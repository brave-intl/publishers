# Request from eyeshade the domain verification token for a site channel
# This depends on the eyeshade API.
# To develop without this dependency, set env var API_EYESHADE_OFFLINE=1
class SiteChannelTokenRequester < BaseApiClient
  attr_reader :channel

  def initialize(channel:)
    @channel = channel
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"

      request.body = "{\"verificationId\": \"#{channel.details.brave_publisher_id}\" }"

      request.body =
          <<~BODY
            {
              "verificationId": "#{channel.details.brave_publisher_id}"
            }
          BODY

      request.url("/v1/owners/#{URI.escape(channel.publisher.owner_identifier)}/verify/#{channel.details.brave_publisher_id}")
    end

    JSON.parse(response.body)["token"]
  end

  def perform_offline
    Rails.logger.info("PublisherTokenRequester generating a verification token offline.")
    SecureRandom.hex(32)
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
