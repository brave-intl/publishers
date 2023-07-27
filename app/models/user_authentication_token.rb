# typed: true

class UserAuthenticationToken < ApplicationRecord
  encrypts :authentication_token

  belongs_to :user, class_name: "Publisher", foreign_key: :user_id

  class << self
    def encryption_key(key: Rails.configuration.pub_secrets[:attr_encrypted_key])
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.configuration.pub_secrets[:attr_encrypted_key]].pack("H*")
      key.byteslice(0, 32)
    end
  end
end
