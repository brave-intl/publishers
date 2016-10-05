class Publisher < ApplicationRecord
  attr_encrypted :bitcoin_address, key: :encryption_key

  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  # base_domain value provided by ledger API
  validates :base_domain, presence: true
  validates :bitcoin_address, bitcoin_address: true, presence: true, if: :should_validate_bitcoin_address?
  validates :email, email: { strict_mode: true }, presence: true
  validates :name, presence: true
  validates :phone, phony_plausible: true

  before_create :generate_verification_token

  # TODO: Show user normalized domain before they commit
  before_validation :normalize_base_domain

  def to_s
    base_domain
  end

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  private

  def generate_verification_token
    # 32 bytes == 256 bits
    self.verification_token = SecureRandom.hex(32)
  end

  def normalize_base_domain
    self.base_domain = PublisherDomainNormalizer.new(base_domain).perform
  rescue Faraday::Error
    errors.add(:base_domain, "can't be normalized because of an API error")
  end

  # This allows for blank bitcoin_address on first create, but
  # requires it on subsequent steps
  def should_validate_bitcoin_address?
    persisted?
  end
end
