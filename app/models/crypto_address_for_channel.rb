class CryptoAddressForChannel < ApplicationRecord
  belongs_to :channel
  belongs_to :crypto_address

  SUPPORTED_CHAINS = ["ETH", "SOL"].freeze
  validates :chain, inclusion: {in: SUPPORTED_CHAINS}
  validates :channel_id, uniqueness: {scope: :chain}

  scope :sol_addresses, -> { where(chain: "SOL") }
  scope :eth_addresses, -> { where(chain: "ETH") }

  def self.eth_address
    eth_addresses.first.&crypto_address.&address
  end

  def self.sol_address
    sol_addresses.first.&crypto_address.&address
  end
end
