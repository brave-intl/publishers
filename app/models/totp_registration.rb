# typed: false

class TotpRegistration < ApplicationRecord
  belongs_to :publisher

  encrypt_column_transition("secret")

  def totp
    ROTP::TOTP.new(secret, issuer: totp_issuer)
  end

  class << self
    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
      key.byteslice(0, 32)
    end
  end

  private

  def totp_issuer
    issuer = "Brave Rewards"

    environment = Rails.env
    if %w[development staging].include?(environment)
      issuer += " (#{environment.capitalize})"
    end

    issuer
  end
end
