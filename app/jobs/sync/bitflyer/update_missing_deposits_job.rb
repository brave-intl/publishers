class Sync::Bitflyer::UpdateMissingDepositsJob < ApplicationJob
  queue_as :low

  def perform
    Publisher.
      joins(:bitflyer_connection).
      joins(:channels).
      where(selected_wallet_provider: BitflyerConnection.class.name.to_s).
      where(channels: { deposit_id: nil }).
      select("channels.id").
      each do |channel_id|
      Sync::Bitflyer::UpdateMissingDepositJob.perform_async(channel_id)
    end
  end
end
