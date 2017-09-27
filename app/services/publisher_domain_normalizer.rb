# Normalize a domain by calling the relevant ledger endpoint
class PublisherDomainNormalizer < BaseApiClient
  attr_reader :domain

  def initialize(domain:)
    # normalize domain by stripping off the protocol, it it exists,
    # and checking if it parses as an http URL
    host_and_path = domain.split(/:\/\//).last
    URI.parse("http://#{host_and_path}")
    @domain = host_and_path
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_ledger_offline]
    url = "http://#{domain}"
    response = connection.get do |request|
      request.params["url"] = url
      request.url("/v2/publisher/identity")
    end
    response_h = JSON.parse(response.body)
    # If the normalized publisher ID is missing, it's on the exclusion list.
    if response_h.include?("publisher")
      response_h["publisher"]
    else
      raise DomainExclusionError.new("Normalized publisher ID unavailable for #{url}")
    end
  end

  def perform_offline
    # Development Gemfile group. If you run in prod move the gem to the top level.
    require "domain_name"
    Rails.logger.info("PublisherDomainNormalizer normalizing offline.")
    domain_name = DomainName(domain)
    unless domain_name.canonical_tld?
      raise DomainExclusionError.new("Normalized publisher ID unavailable for #{domain}")
    end
    domain_name.hostname
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_ledger_base_uri]
  end

  class DomainExclusionError < RuntimeError
  end

  class OfflineNormalizationError < RuntimeError
  end
end
