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
      request_proc = proc do |request|
        if host && host != request["host"] && !follow_all_redirects
          if follow_local_redirects
            raise RedirectError.new("non local redirects prohibited")
          else
            raise RedirectError.new("redirects prohibited")
          end
        end
        host = request["host"]
      end
      response = SsrfFilter.get(uri, max_redirects: limit, request_proc: request_proc, http_options: {open_timeout: 8})
      case response
      when Net::HTTPSuccess
        response
      else
        response.value
      end
    end
  end
end
