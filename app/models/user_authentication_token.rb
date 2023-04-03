# typed: true

class UserAuthenticationToken < ApplicationRecord
  encrypt_column_transition("authentication_token")

  belongs_to :user, class_name: "Publisher", foreign_key: :user_id

  class << self
    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
      key.byteslice(0, 32)
    end
  end
end
