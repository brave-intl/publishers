# typed: ignore
# frozen_string_literal: true

class GeminiConnection < Oauth2::AuthorizationCodeBase
  include WalletProviderProperties
  include Oauth2::Responses

  class WalletCreationError < Oauth2::Errors::ConnectionError; end

  class DuplicateConnectionError < WalletCreationError; end

  class InvalidUserError < WalletCreationError; end

  class CapabilityError < WalletCreationError; end

  JAPAN = "JP"

  has_paper_trail

  belongs_to :publisher
  has_many :gemini_connection_for_channels, dependent: :destroy

  validates :recipient_id, banned_address: true

  encrypts :access_token
  encrypts :refresh_token
  # GeminiConnections do not have a default currency field, it is always assumed to be BAT

  after_commit :create_recipient_ids, on: :create

  # This scope was used once to backfill recipient ids in a background job, not used anywhere else
  # this will be all payable connections, minus connections that are payable because the publisher
  # has the 'blocked_country_exception' flag.
  scope :payable, -> {
    joins(:publisher)
      .where(is_verified: true)
      .where(status: "Active")
      .where.not(recipient_id: nil)
      .where(payout_failed: false)
      .merge(in_supported_country)
  }

  scope :in_supported_country, -> {
    where(country: allowed_countries).or(Publisher.where(blocked_country_exception: true))
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

  def provider_sym
    :gemini
  end

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    is_verified? && status == "Active" && recipient_id && valid_country?
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
    return self if !access_token_expired?
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
    with_refresh do
      verify_through_gemini
      CreateGeminiRecipientIdsJob.perform_later(id)
      self
    end
  end

  def verify_through_gemini
    account = Gemini::Account.find(token: access_token)
    users = account.users
    user = users.find { |u| u.is_verified && u.status == "Active" }

    if !user
      user = users.find { |u| u.is_verified }
      if !user
        LogException.perform(I18n.t(".publishers.gemini_connections.new.no_kyc"), expected: true)
        raise InvalidUserError.new(I18n.t(".publishers.gemini_connections.new.no_kyc"))
      else
        LogException.perform(I18n.t(".publishers.gemini_connections.new.limited_functionality"), expected: true)
        raise CapabilityError.new(I18n.t(".publishers.gemini_connections.new.limited_functionality"))
      end
    end

    return if !user.present?

    validated_country = Gemini::GetValidationService.perform(self, account.account["verificationToken"])
    update!(
      display_name: user.name,
      status: user.status,
      country: validated_country.present? ? validated_country : user.country_code,
      is_verified: user.is_verified
    )
  end

  def wallet_provider_id
    recipient_id
  end

  def with_refresh
    if access_token_expired?
      result = refresh_authorization!

      case result
      when GeminiConnection
        yield
      else
        result
      end
    else
      yield
    end
  end

  def create_recipient_ids
    return unless payable?
    with_refresh do
      CreateGeminiRecipientIdsJob.perform_later(id)
    end
  end

  def allowed_countries
    # hard code just the US for now
    ["US"]
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
          LogException.perform("#{wallet} is not a valid wallet type", expected: true)
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

        conn.verify_through_gemini
        publisher.update!(selected_wallet_provider: conn)
        conn
      end
    end

    def in_use?(recipient_id)
      GeminiConnection.where(recipient_id: recipient_id).joins(:publisher).where.not(publisher: {name: PublisherStatusUpdate::DELETED, email: nil, pending_email: nil}).count > 0
    end

    def oauth2_config
      Oauth2::Config::Gemini
    end

    def encryption_key(key: Rails.configuration.pub_secrets[:attr_encrypted_key])
      [key].pack("H*")
    end

    # Needs to be a class method and not an instance method to allow use in scope queries
    def allowed_countries
      # hard code just the US for now
      ["US"]
    end
  end
end
