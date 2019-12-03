class TotpRegistration < ApplicationRecord
  belongs_to :publisher
  attr_encrypted :secret, key: :encryption_key

  def totp
    ROTP::TOTP.new(secret, issuer: totp_issuer)
  end

  def encryption_key
    self.class.encryption_key
  end

  class << self
    def encryption_key
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
      Rails.application.secrets[:attr_encrypted_key].byteslice(0, 32)
    end
  end

  private

  def totp_issuer
    issuer = "Brave Rewards"

    environment = Rails.env
    if %w(development staging).include?(environment)
      issuer += " (#{environment.capitalize})"
    end

    issuer
  end
end
