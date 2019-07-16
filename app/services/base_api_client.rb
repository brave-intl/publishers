class BaseApiClient < BaseService
  private
  # Make a GET request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns  the response
  def get(path, options = {}, authorization = nil)
    request(:get, path, { params: options }, authorization)
  end

  # Make a POST request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns - [Response] the response
  def post(path, options = {})
    request(:post, path, form: options)
  end

  # Make a PUT request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns [Response] the response
  def put(path, options = {})
    request(:put, path, form: options)
  end

  # Make a PATCH request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns [Response] the response
  def patch(path, options = {})
    request(:patch, path, form: options)
  end

  # Make a DELETE request.
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  # returns [Response] the response
  def delete(path, options = {})
    request(:delete, path, form: options)
  end

  def api_base_uri
    raise "specify me"
  end

  def perform_offline?
    false
  end

  def request(method, path, payload = {}, authorization = nil)
    # Mock out the request
    return Struct.new(:body).new("{}") if perform_offline?

    connection.send(method) do |req|
      req.url [api_base_uri, path].join('')
      req.headers["Authorization"] = authorization || api_authorization_header
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json if method.to_sym.eql?(:post)
      req.params = payload if method.to_sym.eql?(:get)
    end
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
