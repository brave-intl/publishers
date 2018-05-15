class PublisherDefaultCurrencySetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    if publisher.default_currency.blank?
      raise "Publisher #{publisher.id} is missing a default_currency."
    end

    # This raises when response is not 2xx.
    response = connection.patch do |request|
      request.headers["Authorization"] = api_authorization_header
      request.headers["Content-Type"] = "application/json"

      request.body =
          <<~BODY
          {
            "defaultCurrency": "#{publisher.default_currency}" 
          }
      BODY
      request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
    end
    response

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherDefaultCurrencySetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherDefaultCurrencySetter eyeshade offline; only locally updating default_currency.")
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
