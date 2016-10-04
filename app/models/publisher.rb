class Publisher < ApplicationRecord
  attr_encrypted :bitcoin_address, key: :encryption_key

  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: 'US'

  validates :bitcoin_address, bitcoin_address: true, presence: true, if: :should_validate_bitcoin_address?
  validates :email, email: { strict_mode: true }, presence: true
  validates :base_domain, base_domain: true, presence: true
  validates :name, presence: true
  validates :phone, phony_plausible: true

  before_create :generate_verification_token
  before_create :normalize_base_domain

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
    self.base_domain = PublicSuffix.domain(base_domain)
  end

  # This allows for blank bitcoin_address on first create, but
  # requires it on subsequent steps
  def should_validate_bitcoin_address?
    persisted?
  end
end
