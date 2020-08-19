# frozen_string_literal: true

class GeminiConnection < ApplicationRecord
  SUPPORTED_CURRENCIES = ["BAT", "USD", "BTC", "ETH"].freeze

  belongs_to :publisher

  attr_encrypted :access_token, :refresh_token, key: :encryption_key

  after_save :update_default_currency, if: -> { saved_change_to_default_currency? }

  validates :default_currency, inclusion: { in: SUPPORTED_CURRENCIES }, allow_nil: true

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    is_verified? && status == "Active"
  end

  def verify_url
    "#{Rails.application.config.services.gemini[:oauth_uri]}/settings/profile"
  end

  # Public: All the support currency pairs for BAT on the Gemini Exchange
  # https://docs.gemini.com/rest-api/#symbols-and-minimums
  #
  # Returns an array of currencies.
  def supported_currencies
    SUPPORTED_CURRENCIES
  end

  private

  def update_default_currency
    UpdateGeminiDefaultCurrencyJob.perform_async(gemini_id: id)
  end

  def encryption_key
    [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
  end
end
