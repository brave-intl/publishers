# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositsJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  # THere is definitely a rate limit here despite being told there wasn't.  I manually
  # executed the service because the wrong id value was being passed to the job and it succeeded and eventually hit a 429.
  def perform(async: true, wait: 0.1)
    Channel.missing_deposit_id.using_active_bitflyer_connection.select(:id).find_in_batches do |batch|
      batch.each do |channel|
        # FML
        if async
          Sync::Bitflyer::UpdateMissingDepositJob.perform_async(channel.id)
        else
          Sync::Bitflyer::UpdateMissingDepositJob.new.perform(channel.id)
        end

        sleep(wait) if wait
      end
    end
  end
end
