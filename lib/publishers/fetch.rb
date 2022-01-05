# typed: false
require "net/http"
require "ssrf_filter"

module Publishers
  module Fetch
    class RedirectError < StandardError; end

    class ConnectionFailedError < StandardError; end

    class NotFoundError < StandardError; end

    # Fetch URI, following redirects per options
    def fetch(uri:, limit: 10, follow_all_redirects: false, follow_local_redirects: true)
      host = nil
      response = SsrfFilter.get(uri, max_redirects: limit, http_options: {open_timeout: 8}) do |request|
        if host && host != request['host'] && !follow_all_redirects
          if follow_local_redirects
            raise RedirectError.new("non local redirects prohibited")
          else
            raise RedirectError.new("redirects prohibited")
          end
        end

        host = request['host']
      end
      case response
        when Net::HTTPSuccess
          response
        else
          response.value
      end
    end
  end
end
