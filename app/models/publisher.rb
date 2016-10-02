class Publisher < ApplicationRecord
  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: 'US'

  validates :etld, etld: true, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :phone, phony_plausible: true

  # validates :bitcoin_address,
  #   presence: true

  before_create :generate_verification_token
  before_create :normalize_etld

  def to_s
    etld
  end

  private

  def generate_verification_token
    # 32 bytes == 256 bits
    self.verification_token = SecureRandom.hex(32)
  end

  def normalize_etld
    self.etld = PublicSuffix.domain(etld)
  end
end
