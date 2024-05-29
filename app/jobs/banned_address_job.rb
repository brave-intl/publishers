class BannedAddressJob < ApplicationJob
  queue_as :scheduler

  def perform
    Wallet::DisconnectInvalidP2pAddressService.build.call
  end
end
