class BaseApiClient
  private

  def api_base_uri
    raise "specify me"
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
      end
    end
  end

  def proxy_url
    Rails.application.secrets[:proxy_url]
  end
end
