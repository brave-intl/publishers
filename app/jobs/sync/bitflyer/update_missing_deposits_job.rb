# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform(async: true)
    Channel.missing_deposit_id.using_active_bitflyer_connection.select(:id).find_in_batches do |batch|
      batch.each do |channel|
        # FML
        if async
          Sync::Bitflyer::UpdateMissingDepositJob.perform_async(channel.id)
        else
          Sync::Bitflyer::UpdateMissingDepositJob.new.perform(channel.id)
        end
      end
    end
  end
end
