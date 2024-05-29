# typed: true

class DisconnectInvalidP2PAddressService < BuilderBaseService
  def self.build
    new
  end

  def call
    banned = CryptoAddress.all.select(&:banned_address?)
    banned.each do |address|
      SlackMessenger.new(message: "A banned address has been detected in creators: Address #{address.address} on chain #{address.chain} for publisher #{address.publisher.id}", channel: "compliance-bot").perform
    end
    banned&.destroy_all
  end
end
