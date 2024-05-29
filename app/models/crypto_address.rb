class CryptoAddress < ApplicationRecord
  belongs_to :publisher
  has_many :crypto_address_for_channels, dependent: :destroy

  SUPPORTED_CHAINS = ["ETH", "SOL"].freeze
  validates :chain, inclusion: {in: SUPPORTED_CHAINS}
  validate :chain_not_changed?
  validate :address_not_changed?

  validates :address, banned_address: true

  scope :sol_addresses, -> { where(chain: "SOL") }
  scope :eth_addresses, -> { where(chain: "ETH") }

  def chain_not_changed?
    if chain_changed? && persisted?
      errors.add(:chain, "can't be changed")
    end
  end

  def banned_address?
    !valid? && errors.full_messages.any? { |err| err.include?(BannedAddressValidator::MSG) }
  end

  def address_not_changed?
    if address_changed? && persisted?
      errors.add(:address, "can't be changed")
    end
  end
end
