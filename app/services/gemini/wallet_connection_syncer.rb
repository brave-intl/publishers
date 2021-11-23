# typed: true
# frozen_string_literal: true

module Gemini
  class WalletConnectionSyncer
    def self.build
      new
    end

    def call(connection:)
      # TODO move this code out of the model!
      connection.sync_connection!
    end
  end
end
