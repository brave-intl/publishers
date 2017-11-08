# Ask Eyeshade to assign an Uphold account to a Publisher.
class PublisherWalletSetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    if !publisher.uphold_access_parameters
      raise "Publisher #{publisher.id} is missing uphold_access_parameters."
    end

    uphold_access_parameters = JSON.parse(publisher.uphold_access_parameters)
    uphold_access_parameters[:server] = Rails.application.secrets[:uphold_api_uri]

    # This raises when response is not 2xx.
    response = connection.put do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"

      if publisher.publication_type == :site
        request.body =
            <<~BODY
            {
              "provider": "uphold", 
              "parameters": #{JSON.dump(uphold_access_parameters)}, 
              "verificationId": "#{publisher.id}"
            }
        BODY
        request.url("/v2/publishers/#{publisher.brave_publisher_id}/wallet")
      elsif publisher.publication_type == :youtube_channel
        request.body =
            <<~BODY
            {
              "provider": "uphold", 
              "parameters": #{JSON.dump(uphold_access_parameters)}
            }
        BODY
        request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
      else
        begin
          raise "PublisherWalletSetter can't set wallet for publication_type #{publisher.publication_type.to_s}"
        rescue => e
          require "sentry-raven"
          Raven.capture_exception(e)
        end
        return nil
      end
    end
    response

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletSetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletSetter eyeshade offline; only locally updating uphold_access_parameters.")
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
