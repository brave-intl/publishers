class Publisher < ApplicationRecord
  devise :timeoutable, :trackable

  validates :etld,
    presence: true
  validates :email,
    presence: true
  validates :name,
    presence: true
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
