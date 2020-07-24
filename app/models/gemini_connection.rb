# frozen_string_literal: true

class GeminiConnection < ApplicationRecord
  belongs_to :publisher

  attr_encrypted :access_token, :refresh_token, key: :encryption_key

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    is_verified? && status == "Active"
  end

  def verify_url
    "#{Rails.application.config.services.gemini[:oauth_uri]}/settings/profile"
  end

  # Eventually well expand to https://docs.gemini.com/rest-api/#symbols-and-minimums
  def supported_currencies
    ["USD", "BTC", "ETH"]
  end

  private

  def encryption_key
    [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
  end
end
