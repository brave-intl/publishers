class Publisher < ApplicationRecord
  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: 'US'

  validates :etld, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :phone, phony_plausible: true

  # validates :bitcoin_address,
  #   presence: true

  after_validation :generate_verification_token

  def to_s
    etld
  end

  private

  def generate_verification_token
    # 32 bytes == 256 bits
    self.verification_token = SecureRandom.hex(32)
  end
end
