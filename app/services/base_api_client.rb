# typed: false

class BaseApiClient < BaseService
  extend T::Sig
  include Oauth2::Errors

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
      req.url [api_base_uri, path].join("")
      req.headers["Authorization"] = authorization || (defined?(api_authorization_header) && api_authorization_header)
      req.headers["Content-Type"] = "application/json"
      req.headers.merge!(headers)

      req.body = payload.to_json if method.to_sym.eql?(:post) || method.to_sym.eql?(:delete)
      req.params = payload if method.to_sym.eql?(:get)
    end
  end

  def connection(raise_error: true)
    @connection ||= begin
      require "faraday"
      Faraday.new(url: api_base_uri) do |faraday|
        faraday.proxy = proxy_url if proxy_url.present?
        faraday.request :retry, max: retry_count, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2

        # Log level info: Brief summaries
        # Log level debug: Detailed bodies and headers
        faraday.response(:logger, Rails.logger, bodies: true, headers: true)

        if raise_error
          faraday.use(Faraday::Response::RaiseError)
        end

        faraday.adapter Faraday.default_adapter
      end
    end
  end

  ## Some convenience methods used for Sorbet typed responses in various clients
  sig { params(method: Symbol, path: String, response_struct: T.class_of(T::Struct), payload: T.nilable(T::Hash[T.any(Symbol, String), T.untyped]), query: T.nilable(String), headers: T::Hash[T.any(String, Symbol), T.untyped]).returns(T.any(T::Array[T::Struct], T::Struct, Faraday::Response)) }
  def request_and_return(method, path, response_struct, payload: nil, query: nil, headers: {})
    resp = connection(raise_error: false).send(method) do |request|
      request.headers.merge!(headers)
      request.headers["Authorization"] = api_authorization_header
      url = query.nil? ? client_url(path) : "#{client_url(path)}?q=#{query}"

      if payload
        request.body = JSON.dump(payload)
      end

      request.url(url)
    end

    parse_response_to_struct(resp, response_struct)
  end

  def parse_response_to_struct(response, struct)
    return response if !response.success?

    if response.headers["Content-Encoding"].eql?("gzip")
      sio = StringIO.new(response.body)
      gz = Zlib::GzipReader.new(sio)
      data = JSON.parse(gz.read, symbolize_names: true)
    else
      data = JSON.parse(response.body, symbolize_names: true)
    end

    case data
    when Array
      data.map { |obj| adapt_to_struct(struct, obj) }
    when Hash
      adapt_to_struct(struct, data)
    else
      raise "Unknown response type #{data.class}"
    end
  end

  def adapt_to_struct(struct, obj)
    out = {}
    obj[:test] = {stuff: 'lets see'}
    struct.props.keys.each do |key|
              p "*"*100
        p struct.props[key]
      if obj.fetch(key, nil).is_a?(Hash) && struct.props[key][:type] != Hash
        out[key] = adapt_to_struct(struct.props[key][:type], obj.fetch(key, nil))
      else
        out[key] = obj.fetch(key, nil)
      end
    end

    struct.new(out)
  end

  def client_url(path)
    [api_base_uri, path].join("")
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
