# frozen_string_literal: true

module Bitflyer
  class Refresher
    def self.build
      new(impl_refresher: Bitflyer::Auth)
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
        access_token: authorization.access_token,
        refresh_token: authorization.refresh_token,
        expires_in: authorization.expires_in,
        access_expiration_time: authorization.expires_in.seconds.from_now
      )
      # Reload the model so consumers will have the most up to date information.
      bitflyer_connection.reload
    end
  end
end
