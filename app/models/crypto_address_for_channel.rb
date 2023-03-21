class CryptoAddressForChannel < ApplicationRecord
  belongs_to :channel
  belongs_to :crypto_address

  SUPPORTED_CHAINS = ["ETH", "SOL"].freeze
  validates :chain, inclusion: {in: SUPPORTED_CHAINS}

  validates :channel_id, uniqueness: {scope: :chain}
end
