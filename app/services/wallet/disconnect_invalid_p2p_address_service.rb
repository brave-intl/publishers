# typed: true

class Wallet::DisconnectInvalidP2pAddressService < BuilderBaseService
  def self.build
    new
  end

  def call
    prohibited = CryptoAddress.select(&:prohibited_address?)
    prohibited.each do |address|
      SlackMessenger.new(message: "A prohibited address has been detected in creators: Address #{address.address} on chain #{address.chain} for publisher #{address.publisher.id}", channel: "compliance-bot").perform
      address.destroy!
    end

    ServiceRun.record_success!(self.class)
  end
end
