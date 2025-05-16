# typed: true

class Wallet::DisconnectInvalidP2pAddressService < BuilderBaseService
  def self.build
    new
  end

  def call
    banned = CryptoAddress.select(&:banned_address?)
    banned.each do |address|
      SlackMessenger.new(message: "A banned address has been detected in creators: Address #{address.address} on chain #{address.chain} for publisher #{address.publisher.id}", channel: "compliance-bot").perform
      address.destroy!
    end
  end
end
