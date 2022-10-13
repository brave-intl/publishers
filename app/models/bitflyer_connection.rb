# typed: ignore
# frozen_string_literal: true

class BitflyerConnection < Oauth2::AuthorizationCodeBase
  include WalletProviderProperties

  SUPPORTED_CURRENCIES = ["BAT", "USD"].freeze
  JAPAN = "JP"

  has_paper_trail

  belongs_to :publisher
  attr_encrypted :access_token, :refresh_token, key: proc { |record| record.class.encryption_key }
  validates :recipient_id, uniqueness: true, allow_blank: true
  validates :default_currency, inclusion: {in: SUPPORTED_CURRENCIES}, allow_nil: true

  # FIXME: This should be reused, but I don't want to deal with sorbet atm
  scope :with_expired_tokens, -> {
    where("access_expiration_time <= ?", Date.today)
  }

  scope :with_active_connection, -> {
    where(oauth_refresh_failed: false)
  }

  scope :refreshable, -> {
    with_active_connection.with_expired_tokens
  }

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    true
  end

  def valid_country?(country_code = JAPAN, provider_sym = :bitflyer)
    true
  end

  def verify_url
    ""
  end

  def is_valid_connection?
    access_expiration_time.present? && encrypted_access_token.present? && encrypted_refresh_token.present?
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

  # is_valid_connection? is handling the fact that many otherwise functional
  # bitflyer connections were created without an access_expiration_time
  # and because of this the access_token_expired? check always returns false (because the nil value for the timestamp)

  # I'm moving all the wallet models to requiring this field and using it to ensure we only refresh connections
  # when we actually need to.  This cuts down on requests and also deals with possible race conditions
  # that I've encountered else where (Gemini).
  def refresh_authorization!
    return self if is_valid_connection? && !access_token_expired?

    # Bitflyer is returning 403 for bad tokens with HTML content
    # Every record that is throwing this has an expired access token or is very old.
    # Clearly a broken case.
    super do |failure_result|
      raise failure_result if failure_result.response.code != "403"
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

    # Note: The logic implemented here is what I would usually go to a service for due to it's multi-model complexity
    # I.e. Service::Bitflyer::Create
    def create_new_connection!(publisher, access_token_response)
      # Oauth2::Responses::AccessTokenResponse: T.nilable(expires_in)
      access_expiration_time = access_token_response.expires_in.present? ? access_token_response.expires_in.seconds.from_now : nil

      # Do everything in a transaction so hopefully we begin tamping down data artifacts
      ActiveRecord::Base.transaction do
        # Cleanup artifacts in absence of any actual uniqueness verifications
        # We have so many empty connections
        BitflyerConnection.where(publisher_id: publisher.id).delete_all

        conn = BitflyerConnection.create!(
          publisher_id: publisher.id,
          access_token: access_token_response.access_token,
          refresh_token: access_token_response.refresh_token,
          expires_in: access_token_response.expires_in,
          access_expiration_time: access_expiration_time,
          display_name: access_token_response.account_hash,
          default_currency: "BAT"
        )

        publisher.update!(selected_wallet_provider: conn)
      end
    end

    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      [key].pack("H*")
    end
  end
end
