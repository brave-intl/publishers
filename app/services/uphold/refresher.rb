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
    def call(uphold_connection:)
      # Ensure we have an refresh_token.
      refresh_token = uphold_connection.refresh_token

      return if refresh_token.blank?

      refreshment = @impl_refresher.refresh(uphold_connection)

      # Update with the latest Authorization
      uphold_connection.uphold_access_parameters = refreshment
      uphold_connection.save!

      uphold_connection.reload
    end
  end
end
