# Normalize a domain by calling the relevant ledger endpoint
class PublisherDomainNormalizer
  attr_reader :domain

  def initialize(domain:)
    @domain = domain
  end

  def perform
    response = connection.get do |request|
      request.params["url"] = "http://#{domain}"
      request.url("/v1/publisher/identity")
    end
    JSON.parse(response.body)["publisher"]
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_ledger_base_uri]
  end

  def connection
    @connection ||= begin
      require "faraday"
      Faraday.new(url: api_base_uri) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response(:logger, Rails.logger)
        faraday.use(Faraday::Response::RaiseError)
      end
    end
  end
end
