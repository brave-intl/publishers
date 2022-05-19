# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform(async: true)
    Channel.missing_deposit_id.using_active_bitflyer_connection.select(:id).find_in_batches do |batch|
      batch.each do |id|
        if async
          Sync::Bitflyer::UpdateMissingDepositJob.perform_async(id)
        else
          Sync::Bitflyer::UpdateMissingDepositJob.new.perform(id)
        end
      end
    end
  end
end
