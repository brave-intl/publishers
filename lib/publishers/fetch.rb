require 'net/http'

module Publishers
  module Fetch
    class RedirectError < StandardError; end
    class ConnectionFailedError < StandardError; end

    # Fetch URI, following redirects per options
    def fetch(uri:, limit: 10, follow_all_redirects: false, follow_local_redirects: true)
      raise RedirectError.new('too many HTTP redirects') if limit == 0

      begin
        response = Net::HTTP.get_response(uri)

        case response
          when Net::HTTPSuccess then
            response
          when Net::HTTPRedirection then
            raise RedirectError.new('redirects prohibited') unless follow_all_redirects || follow_local_redirects

            location = response['location']
            new_uri = URI.parse(location)

            # Tests if redirect is relative or if it's to a new host or page in the same domain
            local_redirect = new_uri.relative? || new_uri.host.end_with?(uri.host)

            if local_redirect && follow_local_redirects
              new_uri = URI(uri + location)
            elsif !follow_all_redirects
              raise RedirectError.new('non local redirects prohibited')
            end

            fetch(uri: new_uri,
                  limit: limit - 1,
                  follow_all_redirects: follow_all_redirects,
                  follow_local_redirects: follow_local_redirects)
          else
            response.value
        end

      rescue => e
        raise ConnectionFailedError.new(e)
      end
    end
  end
end
