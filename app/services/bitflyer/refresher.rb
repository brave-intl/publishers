# frozen_string_literal: true

module Bitflyer
  class Refresher
    REFRESH_TOKEN = "refresh_token"

    def self.build
      new(impl_refresher: RefresherHttpImpl)
    end

    def initialize(impl_refresher:)
      @impl_refresher = impl_refresher
    end

    # Makes a request to the Bitflyer API to refresh the current access_token
    def call(bitflyer_connection:)
      # Ensure we have an refresh_token.
      refresh_token = bitflyer_connection.refresh_token

      return if refresh_token.blank?

      authorization = @impl_refresher.refresh(token: refresh_token)

      # Update with the latest Authorization
      bitflyer_connection.update!(
        access_token: authorization['access_token'],
        refresh_token: authorization['refresh_token'],
        expires_in: authorization['expires_in'],
        access_expiration_time: authorization['expires_in'].seconds.from_now
      )
      # Reload the model so consumers will have the most up to date information.
      bitflyer_connection.reload
    end

    class RefresherHttpImpl
      # Public: Requests a refresh token from the Bitflyer /auth/token.
      #
      # token - The refresh token made from initial token authorization flow
      #
      # Returns an auth object
      def self.refresh(token:, http_client: Bitflyer::Http.new)
        # This is a temporary stop gap until this issue is addressed
        # https://github.com/brave-intl/publishers/issues/2779

        body = {
          client_id: Bitflyer::Http.client_id,
          client_secret: Bitflyer::Http.client_secret,
          grant_type: REFRESH_TOKEN,
          scope: Bitflyer::Http.oauth_scope,
          refresh_token: token,
        }
        response = http_client.send(:post, Bitflyer::Http.oauth_path, body)
        JSON.parse(response.body)
      end
    end
  end
end
