# typed: ignore

class Sync::Bitflyer::UpdateMissingDepositJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(channel_id)
    Wallet::UpdateBitflyerDepositIdService.build.call(Channel.find_by_id!(channel_id))
  end
end
