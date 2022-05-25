# typed: ignore
# frozen_string_literal: true

class BitflyerConnection < Oauth2::AuthorizationCodeBase
  include WalletProviderProperties

  SUPPORTED_CURRENCIES = ["BAT", "USD", "BTC", "ETH"].freeze
  JAPAN = "JP"

  has_paper_trail

  belongs_to :publisher
  attr_encrypted :access_token, :refresh_token, key: proc { |record| record.class.encryption_key }
  validates :recipient_id, uniqueness: true, allow_blank: true
  validates :default_currency, inclusion: {in: SUPPORTED_CURRENCIES}, allow_nil: true

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    true
  end

  def japanese_account?
    country&.upcase == JAPAN
  end

  def verify_url
    ""
  end

  # Public: All the support currency pairs for BAT on the Bitflyer Exchange
  # https://bitflyer.com/en-us/api
  #
  # Returns an array of currencies.
  def supported_currencies
    SUPPORTED_CURRENCIES
  end

  def access_token_expired?
    access_expiration_time.present? && Time.now > access_expiration_time
  end

  def fetch_refresh_token
    refresh_token
  end

  def update_access_tokens!(refresh_token_response)
    update!(
      access_token: refresh_token_response.access_token,
      refresh_token: refresh_token_response.refresh_token,
      expires_in: refresh_token_response.expires_in,
      access_expiration_time: refresh_token_response.expires_in.seconds.from_now
    )

    self
  end

  # This is a temporary work around to gaurd against potential
  # race conditions that have caused broken conditions in other connections such as Gemini
  # Bitflyer is the first connection that is going to run a scheduled job running refresh
  # so I am trying to be very cautious.  Updating this in the base class method
  # broke too many specs to deal with right now so for the sake of forward progress
  # this is my resolution.
  def refresh_authorization!
    return self if !access_token_expired? && access_token

    # Bitflyer is returning 403 for bad tokens with HTML content
    # Every record that is throwing this has an expired access token or is very old.

    # Clearly a broken case.
    super do |result|
      raise result if result.response.code != "403"
      record_refresh_failure!
      ErrorResponse.new(error: "invalid_grant", error_description: "bitflyer has returned a forbidden 403")
    end
  end

  def sync_connection!
    refresh_authorization!
  end

  class << self
    def provider_name
      "Bitflyer"
    end

    def oauth2_config
      Oauth2::Config::Bitflyer
    end

    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      [key].pack("H*")
    end
  end
end
