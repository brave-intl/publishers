# Normalize a domain by calling the relevant ledger endpoint
class PublisherDomainNormalizer < BaseApiClient
  attr_reader :domain

  def initialize(domain:)
    @domain = domain
  end

  def perform
    url = "http://#{domain}"
    response = connection.get do |request|
      request.params["url"] = url
      request.url("/v1/publisher/identity")
    end
    response_h = JSON.parse(response.body)
    # If the normalized publisher ID is missing, it's on the exclusion list.
    if response_h.include?("publisher")
      response_h["publisher"]
    else
      raise DomainExclusionError.new("Normalized publisher ID unavailable for #{url}")
    end
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_ledger_base_uri]
  end

  class DomainExclusionError < RuntimeError
  end
end
