# typed: false
require "net/http"
require "ssrf_filter"

module Publishers
  module Fetch
    class RedirectError < StandardError; end

    class ConnectionFailedError < StandardError; end

    class NotFoundError < StandardError; end

    # Fetch URI, following redirects per options
    def fetch(uri:, limit: 10)
      response = SsrfFilter.get(uri, max_redirects: limit, http_options: {open_timeout: 8})
      case response
        when Net::HTTPSuccess
          response
        else
          response.value
      end
    end
  end
end
