# typed: ignore

class Sync::Bitflyer::UpdateMissingDepositJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: false

  def perform(channel_id)
    Bitflyer::UpdateDepositIdService.build.call(Channel.find_by_id!(channel_id))
  end
end
