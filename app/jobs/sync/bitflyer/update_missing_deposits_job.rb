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
      # For now I'm only allowing this to be sent once so we don't spam users, it's unclear to me how often this gets run
      .where(:bitflyer_connection, {oauth_refresh_failed: false, oauth_failure_email_sent: false}) # There is no point in attempting this on failed connections
      .select("channels.id")
      .each do |result|
      channel_id = result["id"]
      Sync::Bitflyer::UpdateMissingDepositJob.perform_async(channel_id)
    end
  end
end
