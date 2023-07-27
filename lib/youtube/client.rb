# typed: true

#
# Note: As of 2/24/22 this is not implemented, it is mostly opportunistic consolidation of http requests
# that have been split out into individual Getter services.  My goal is to create individual http clients
# for each 3rd party API, deprecate the individual getter services, and limit actions performed in the Service classes
# to simply mediating the interactions between the external API and the application.
module Youtube
  class Client < BaseApiClient
    def initialize(token: Rails.configuration.pub_secrets[:youtube_api_key])
      @token = token
    end

    def channels(query: nil)
      path = "/youtube/v3/channels"

      if query.present?
        path << "?#{query.to_query}"
      end

      request(:get, path)
    end

    def api_authorization_header
      "Bearer #{@token}"
    end

    def api_base_uri
      "https://www.googleapis.com"
    end
  end
end
