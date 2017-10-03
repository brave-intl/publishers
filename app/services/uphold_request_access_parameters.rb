require "faraday"

class UpholdRequestAccessParameters
  class InvalidGrantError < StandardError; end

  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def connection
    @connection ||= begin
      Faraday.new(url: api_base_uri) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.proxy(proxy_url) if proxy_url.present?
        # Log level info: Brief summaries
        # Log level debug: Detailed bodies and headers
        faraday.response(:logger, Rails.logger, bodies: true, headers: true)
        faraday.use(Faraday::Response::RaiseError)
        faraday.basic_auth(Rails.application.secrets[:uphold_client_id], Rails.application.secrets[:uphold_client_secret])
      end
    end
  end

  def proxy_url
    Rails.application.secrets[:proxy_url]
  end

  def perform
    response = connection.post do |request|
      request.url("#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      request.body = "code=#{@publisher.uphold_code}&grant_type=authorization_code"
    end

    response.body
  rescue Faraday::ClientError => e
    Rails.logger.warn("UpholdRequestAccessParameters ClientError: #{e}")
    if e.response && e.response[:status] == 400 && e.response[:body] == '{"error":"invalid_grant"}'
      # The Code was invalid and could not be used to retrieve access parameters. Raise an exception so this
      # can be handled externally
      raise InvalidGrantError.new
    else
      nil
    end
  rescue Faraday::Error => e
    Raven.capture_exception(e)
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
