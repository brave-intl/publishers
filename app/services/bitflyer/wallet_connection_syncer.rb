# frozen_string_literal: true

module Bitflyer
  class WalletConnectionSyncer
    def self.build
      new
    end

    def call(connection:)
      # TODO enable this once refreshing verified to work
      # Bitflyer::Refresher.build.call(bitflyer_connection: connection)
    end
  end
end
