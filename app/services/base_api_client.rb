class BaseApiClient < BaseService
  private

  # Make a GET request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns  the response
  def get(path, options = {}, authorization = nil, headers = {})
    request(:get, path, options, authorization, headers)
  end

  # Make a POST request.
  #
  # path    - [String] the path relative to the endpoint
  # options - [Hash] the parameters to supply
  #
  # returns - [Response] the response
  def post(path, options = {}, authorization = nil, headers = {})
    request(:post, path, options, authorization, headers)
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
    request(:delete, path, options)
  end

  def api_base_uri
    raise "specify me"
  end

  def perform_offline?
    false
  end

  def request(method, path, payload = {}, authorization = nil, headers = {})
    # Mock out the request
    return Struct.new(:body).new("{}") if perform_offline?

    connection.send(method) do |req|
      req.url [api_base_uri, path].join('')
      req.headers["Authorization"] = authorization || api_authorization_header
      req.headers['Content-Type'] = 'application/json'
      req.headers.merge!(headers)

      req.body = payload.to_json if method.to_sym.eql?(:post) || method.to_sym.eql?(:delete)
      req.params = payload if method.to_sym.eql?(:get)
    end
  end

  def connection
    @connection ||= begin
      require "faraday"
      Faraday.new(url: api_base_uri) do |faraday|
        if !api_base_uri.include?("eyeshade")
          faraday.proxy = proxy_url if proxy_url.present?
        end
        faraday.request :retry, max: retry_count, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2

        # Log level info: Brief summaries
        # Log level debug: Detailed bodies and headers
        faraday.response(:logger, Rails.logger, bodies: true, headers: true)
        faraday.use(Faraday::Response::RaiseError)
        faraday.adapter Faraday.default_adapter
      end
    end
  end

  # The default retry count is 2. However, a subclass could introduce their own retry_count.
  # https://github.com/lostisland/faraday/blob/0ebc233513d186bebb940ec0260278823f5d2a22/lib/faraday/request/retry.rb#L5-L24
  def retry_count
    2
  end

  def proxy_url
    Rails.application.secrets[:proxy_url]
  end
end
