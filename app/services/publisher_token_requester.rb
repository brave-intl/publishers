# Given a Publisher, request from eyeshade the domain verification token
# This depends on the eyeshade API.
# To develop without this dependency, set env var API_EYESHADE_OFFLINE=1
class PublisherTokenRequester < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]
    response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      qp = "show_verification_status=#{publisher.show_verification_status?}"
      request.url("/v1/publishers/#{publisher.brave_publisher_id}/verifications/#{publisher.id}?#{qp}")
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
