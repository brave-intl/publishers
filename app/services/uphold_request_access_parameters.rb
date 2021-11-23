# typed: true
require "faraday"

class UpholdRequestAccessParameters < BaseService
  class InvalidGrantError < StandardError; end

  def initialize(uphold_code:, secret_used: nil)
    @uphold_code = uphold_code
  end

  def connection
    @connection ||= Faraday.new(url: api_base_uri) do |faraday|
      faraday.proxy = proxy_url if proxy_url.present?
      # Log level info: Brief summaries
      # Log level debug: Detailed bodies and headers
      faraday.response(:logger, Rails.logger, bodies: true, headers: true)
      faraday.use(Faraday::Response::RaiseError)
      faraday.basic_auth(client_id, client_secret)
      faraday.adapter Faraday.default_adapter
    end
  end

  def client_id
    Rails.application.secrets[:uphold_client_id]
  end

  def client_secret
    Rails.application.secrets[:uphold_client_secret]
  end

  def proxy_url
    Rails.application.secrets[:proxy_url]
  end

  def perform
    response = connection.post do |request|
      request.url("#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      request.body = "code=#{@uphold_code}&grant_type=authorization_code"
    end

    response.body
  rescue Faraday::ClientError => e
    Rails.logger.warn("UpholdRequestAccessParameters ClientError: #{e}")
    if e.response && e.response[:status] == 400 && e.response[:body] == '{"error":"invalid_grant"}'
      # The Code was invalid and could not be used to retrieve access parameters. Raise an exception so this
      # can be handled externally
      raise InvalidGrantError.new
    end
  rescue Faraday::Error => e
    Rails.logger.warn("UpholdRequestAccessParameters #perform error: #{e}")
    nil
  end

  private

  def api_base_uri
    Rails.application.secrets[:uphold_api_uri]
  end

  def api_authorization_header
  end
end
