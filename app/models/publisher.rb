class Publisher < ApplicationRecord
  validates :etld,
    presence: true
  validates :email,
    presence: true
  validates :name,
    presence: true
  validates :bitcoin_address,
    presence: true

  after_validation :generate_verification_token

  private

  def generate_verification_token
    # 32 bytes == 256 bits
    self.verification_token = SecureRandom.hex(32)
  end
end
