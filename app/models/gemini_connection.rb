# typed: ignore
# frozen_string_literal: true

class GeminiConnection < Oauth2::AuthorizationCodeBase
  include WalletProviderProperties
  include Oauth2::Responses

  class WalletCreationError < Oauth2::Errors::ConnectionError; end

  class DuplicateConnectionError < WalletCreationError; end

  class InvalidUserError < WalletCreationError; end

  JAPAN = "JP"

  has_paper_trail

  belongs_to :publisher
  has_many :gemini_connection_for_channels
  attr_encrypted :access_token, :refresh_token, key: proc { |record| record.class.encryption_key }
  # GeminiConnections do not have a default currency field, it is always assumed to be BAT

  scope :payable, -> {
    where(is_verified: true)
      .where(status: "Active")
      .where.not(recipient_id: nil)
  }

  scope :with_expired_tokens, -> {
    where("access_expiration_time <= ?", Date.today)
  }

  scope :with_active_connection, -> {
    where(oauth_refresh_failed: false)
  }

  scope :refreshable, -> {
    with_active_connection.with_expired_tokens
  }

  enum recipient_id_status: {
    pending: 0,
    duplicate: 1,
    present: 2
  }, _prefix: :recipient_id

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    is_verified? && status == "Active" && recipient_id
  end

  def default_currency
    "BAT"
  end

  def japanese_account?
    country&.upcase == JAPAN
  end

  def verify_url
    "#{Rails.application.config.services.gemini[:oauth_uri]}/settings/profile"
  end

  def access_token_expired?
    access_expiration_time.present? && Time.now > access_expiration_time
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

  def fetch_refresh_token
    refresh_token
  end

  # Gemini returns a 401 with a valid oauth2 error message
  # This is a clear case of refresh failure so we want to handle it
  # I'm handling this in the GeminiConnection model specifically
  # as this is not a valid Oauth2 spec response and thus
  # I do not want to contaminate the Oauth2::AuthenticationCodeClient
  def refresh_authorization!
    super do |result|
      raise result if result.response.code != "401"

      record_refresh_failure!

      # Catch the valid response body with invalid code
      begin
        body = JSON.parse(result.response.body, symbolize_names: true)
        ErrorResponse.new(error: body[:error], error_description: body[:error_description])
      rescue
        # If it's not a valid response body, it's still an UnknownError, raise
        raise result
      end
    end
  end

  def sync_connection!
    # FIXME: This was a quick hack, to resolve a bug.
    # Clean it up later.
    if access_token_expired?
      result = refresh_authorization!

      case result
      when GeminiConnection
        verify_through_gemini
        self
      else
        result
      end
    else
      verify_through_gemini
      self
    end
  end

  def verify_through_gemini
    users = Gemini::Account.find(token: access_token).users
    user = users.find { |u| u.is_verified && u.status == "Active" }

    # If we couldn't find a verified account we'll take the first user.
    user ||= users.first

    return if !user.present?
    check_country(user.country_code, :gemini)

    update!(
      display_name: user.name,
      status: user.status,
      country: user.country_code,
      is_verified: user.is_verified
    )
  end

  class << self
    def provider_name
      "Gemini"
    end

    def create_new_connection!(publisher, access_token_response)
      # Oauth2::Responses::AccessTokenResponse: T.nilable(expires_in)
      access_expiration_time = access_token_response.expires_in.present? ? access_token_response.expires_in.seconds.from_now : nil
      recipient = Gemini::RecipientId.find_or_create(token: access_token_response.access_token)

      raise ValueError unless recipient.recipient_id.present?

      ActiveRecord::Base.transaction do
        # Cleanup artifacts in absence of any actual uniqueness verifications
        # We have so many empty connections
        GeminiConnection.where(publisher_id: publisher.id).delete_all

        if GeminiConnection.in_use?(recipient.recipient_id)
          raise DuplicateConnectionError.new("Could not establish Gemini connection. It looks like your Gemini account is already connected to another Brave Creators account. Your Gemini account can only be connected to one Brave Creators account at a time.")
        end

        conn = GeminiConnection.create!(
          publisher_id: publisher.id,
          access_token: access_token_response.access_token,
          refresh_token: access_token_response.refresh_token,
          expires_in: access_token_response.expires_in,
          access_expiration_time: access_expiration_time,
          recipient_id: recipient.recipient_id,
          display_name: "Pending",
          recipient_id_status: "present"
        )

        resp = conn.verify_through_gemini

        raise InvalidUserError.new("Authorization failed, we Could not verify your Gemini user.") if resp.nil?

        publisher.update!(selected_wallet_provider: conn)
      end
    end

    def in_use?(recipient_id)
      GeminiConnection.where(recipient_id: recipient_id).joins(:publisher).where.not(publisher: {name: PublisherStatusUpdate::DELETED, email: nil, pending_email: nil}).count > 0
    end

    def oauth2_config
      Oauth2::Config::Gemini
    end

    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      [key].pack("H*")
    end
  end
end
