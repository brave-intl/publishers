# typed: ignore

class SetPayoutsInProgressJob < ApplicationJob
  queue_as :scheduler

  PAYOUTS_IN_PROGRESS = "payouts_in_progress".freeze

  CONNECTIONS = [BitflyerConnection.name.underscore,
    GeminiConnection.name.underscore,
    PaypalConnection.name.underscore,
    UpholdConnection.name.underscore].freeze

  def perform
    Rails.cache.write(PAYOUTS_IN_PROGRESS,
      CONNECTIONS.collect { |connection| [connection, true] }.to_h)
  end
end
