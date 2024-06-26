require "eth"
require "rbnacl"
require "base58"

class Util::CryptoUtils
  include Eth

  def self.verify_solana_address(signature, address, message, current_publisher)
    verify_key = RbNaCl::VerifyKey.new(Base58.base58_to_binary(address, :bitcoin))
    verify_key.verify(Base58.base58_to_binary(signature, :bitcoin), message)
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end

  def self.verify_ethereum_address(signature, address, message, current_publisher)
    signature_pubkey = Eth::Signature.personal_recover message, signature
    signature_address = Eth::Util.public_key_to_address signature_pubkey
    # Eth addresses are case insensitive
    signature_address.address.downcase == address.downcase
  rescue => e
    LogException.perform(e, publisher: current_publisher)
    false
  end
end
