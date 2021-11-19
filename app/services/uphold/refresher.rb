# typed: true
# frozen_string_literal: true

module Uphold
  class Refresher
    def self.build
      new(impl_refresher: Uphold::Models::Authorization.new)
    end

    def initialize(impl_refresher:)
      @impl_refresher = impl_refresher
    end

    # Makes a request to the Uphold API to refresh the current access_token
    def call(uphold_connection:, ignore_expiration: false)
      # Ensure we have an refresh_token.

      if !ignore_expiration
        return unless uphold_connection.authorization_expired?
      end

      return if uphold_connection.refresh_token.blank?

      authorization = @impl_refresher.refresh_authorization(uphold_connection)

      if authorization
        # add expiration time
        authorization_hash = JSON.parse(authorization)

        if authorization_hash["error"]
          return
        end

        authorization_hash["expiration_time"] = authorization_hash["expires_in"].to_i.seconds.from_now

        # Update with the latest Authorization
        uphold_connection.uphold_access_parameters = JSON.dump(authorization_hash)
        uphold_connection.save!

        uphold_connection.reload
      end
    end
  end
end
