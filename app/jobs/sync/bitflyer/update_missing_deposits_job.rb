# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositsJob < ApplicationJob
  queue_as :low

  def perform(notify: false)
    Channel.missing_deposit_id.using_active_bitflyer_connection.select(:id).find_in_batches do |batch|
      batch.each do |id|
        Sync::Bitflyer::UpdateMissingDepositJob.perform_async(id, notify: notify)
      end
    end
  end
end
