class UpholdRequestAccessParameters
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def connection
    @connection ||= begin
      require "faraday"
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
  rescue Faraday::Error => e
    Rails.logger.warn("UpholdRequestAccessToken #perform error: #{e}")
    nil
  end

  private

  def api_base_uri
    Rails.application.secrets[:uphold_api_uri]
  end

  def api_authorization_header
  end
end
