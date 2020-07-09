# frozen_string_literal: true

class GeminiConnection < ApplicationRecord
  belongs_to :publisher

  attr_encrypted :access_token, :refresh_token, key: :encryption_key

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  private

  def encryption_key
    [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
  end
end
