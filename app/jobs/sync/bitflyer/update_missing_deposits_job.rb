# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositsJob < ApplicationJob
  queue_as :low

  def perform
    Publisher
      .joins(:bitflyer_connection)
      .joins(:channels)
      .where(selected_wallet_provider_type: BitflyerConnection.name)
      .where.not(selected_wallet_provider_id: nil)
      .where(channels: {deposit_id: nil})
      .select("channels.id")
      .each do |result|
      channel_id = result["id"]
      Sync::Bitflyer::UpdateMissingDepositJob.perform_async(channel_id)
    end
  end
end
