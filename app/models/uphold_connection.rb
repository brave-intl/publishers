# typed: true
# frozen_string_literal: true

class UpholdConnection < Oauth2::AuthorizationCodeBase
  # Here for debugging, let's you toggle the KYC requirement for creating
  # a connection.
  class_attribute :strict_create, default: true

  class WalletCreationError < Oauth2::Errors::ConnectionError; end

  class UnverifiedConnectionError < WalletCreationError; end

  class DuplicateConnectionError < WalletCreationError; end

  class FlaggedConnectionError < WalletCreationError; end

  class InsufficientScopeError < WalletCreationError; end

  class CapabilityError < WalletCreationError; end

  include WalletProviderProperties
  include Uphold::Types

  has_paper_trail only: [:is_member, :member_at, :uphold_id, :address, :status, :default_currency]

  UPHOLD_CODE_TIMEOUT = 5.minutes
  UPHOLD_ACCESS_PARAMS_TIMEOUT = 2.hours
  UPHOLD_CARD_LABEL = "Brave Rewards"

  # Snooze for the next ~ 80 years, this is what I consider forever from now :)
  FOREVER_DATE = DateTime.new(2100, 1, 1)

  USE_BROWSER = 1

  attr_encrypted :uphold_code, key: proc { |record| record.class.encryption_key }
  attr_encrypted :uphold_access_parameters, key: proc { |record| record.class.encryption_key }

  class UpholdAccountState
    REAUTHORIZATION_NEEDED = :reauthorization_needed
    VERIFIED = :verified
    ACCESS_PARAMETERS_ACQUIRED = :access_parameters_acquired
    CODE_ACQUIRED = :code_acquired
    UNCONNECTED = :unconnected
    # (Albert Wang): Consider adding refactoring all of the above states as they
    # aren't valid states: https://uphold.com/en/developer/api/documentation/#user-object
    RESTRICTED = :restricted
    BLOCKED = :blocked
    OLD_ACCESS_CREDENTIALS = :old_access_credentials
  end

  OK = "ok"
  PENDING = "pending"
  BLOCKED = "blocked"
  RESTRICTED = "restricted"

  JAPAN = "JP"

  #################
  # Associations
  ################
  belongs_to :publisher
  has_many :uphold_connection_for_channels

  #################
  # Callbacks
  ################

  after_save :update_site_banner_lookup!, if: -> { T.bind(self, UpholdConnection).saved_change_to_attribute(:is_member) }
  after_save :update_promo_status, if: -> { T.bind(self, UpholdConnection).saved_change_to_attribute(:is_member) }

  #################
  # Scopes
  ################
  #
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

  # TODO: Deprecate ASAP
  scope :has_stale_uphold_access_parameters, -> {
    where.not(encrypted_uphold_access_parameters: nil)
      .where("updated_at < ?", UPHOLD_ACCESS_PARAMS_TIMEOUT.ago)
  }

  # TODO: Deprecate ASAP
  # publishers that have uphold codes that have been sitting for five minutes
  # can be cleared if publishers do not create wallet within 5 minute window
  scope :has_stale_uphold_code, -> {
    where.not(encrypted_uphold_code: nil)
      .where("updated_at < ?", UPHOLD_CODE_TIMEOUT.ago)
  }

  #################
  # Public Instance Methods
  ################

  # TODO: Deprecate ASAP
  def receive_uphold_code(code)
    update(
      uphold_code: code,
      uphold_state_token: nil,
      uphold_access_parameters: nil,
      uphold_verified: false
    )
  end

  # This state token is generated and must be unique when connecting to uphold.
  def prepare_uphold_state_token!
    self.uphold_state_token = SecureRandom.hex(64).to_s
    save!
  end

  def scope
    @scope ||= JSON.parse(uphold_access_parameters || "{}").try(:[], "scope") || []
  end

  def can_read_transactions?
    scope.include?("transactions:read")
  end

  # Public: Determines if a user needs to reconnect their Uphold account.
  #         If the user doesn't have a valid acess scope, or Uphold returns a 401
  #         then we tell the user to re-authorize.
  #
  # Returns true or false
  def uphold_reauthorization_needed?
    # TODO Let's make sure that if we can't access the user's information then we set uphold_verified? to false
    # Perhaps through a rescue on 401
    uphold_verified? &&
      (uphold_access_parameters.blank? || uphold_details.nil? || scope.exclude?("cards:write") || status&.to_sym == UpholdAccountState::OLD_ACCESS_CREDENTIALS)
  end

  def uphold_details
    if access_token.nil?
      record_refresh_failure!
      return
    end

    refresh_authorization!
    result = connection_client.users.get

    case result
    when UpholdUser
      @user = result
    end
  end

  def uphold_status
    send_blocked_message if status == UpholdAccountState::BLOCKED

    if status == UpholdAccountState::RESTRICTED
      UpholdAccountState::RESTRICTED
    elsif uphold_reauthorization_needed?
      UpholdAccountState::REAUTHORIZATION_NEEDED
    elsif uphold_verified? && !is_member?
      UpholdAccountState::RESTRICTED
    elsif uphold_verified? && is_member?
      UpholdAccountState::VERIFIED
    else
      UpholdAccountState::UNCONNECTED
    end
  end

  def blocked?
    status == UpholdConnection::BLOCKED
  end

  def username
    # This doesn't exist on the uphold user object.
    # and the previous model did not do anything but parse the response.
    # It probably has always been nil
    # https://uphold.com/en/developer/api/documentation/#user-object#
    nil
  end

  def unconnected?
    uphold_status == UpholdAccountState::UNCONNECTED
  end

  def payable?
    uphold_status == UpholdAccountState::VERIFIED && status == OK
  end

  def verify_url
    Rails.application.secrets[:uphold_dashboard_url]
  end

  def can_create_uphold_cards?
    uphold_verified? &&
      uphold_access_parameters.present? &&
      scope.include?("cards:write") &&
      status != UpholdConnection::BLOCKED &&
      status != UpholdConnection::PENDING &&
      !publisher&.excluded_from_payout
  end

  def create_uphold_cards
    return unless can_create_uphold_cards? && default_currency.present?
    T.unsafe(publisher).channels.each do |channel|
      CreateUpholdChannelCardJob.perform_later(uphold_connection_id: id, channel_id: channel.id)
    end
  end

  def missing_card?
    (default_currency_confirmed_at.present? && address.blank?) || !valid_card?
  end

  # Public: Returns a list of supported currencies for a publisher
  #
  # Returns an array of currencies
  def supported_currencies
    currencies
  end

  # Calls the Uphold API and checks
  #   - if the address exists
  #   - the card is in the same currency as the publisher's chosen currency
  #
  # Returns true if the checks pass, returns false if the Uphold API returns a 404 Not Found, or the address doesn't exist.
  def valid_card?
    return false if address.blank?

    card = UpholdClient.card.find(
      uphold_connection: self,
      id: address
    )

    card&.currency.eql?(default_currency)
  rescue Faraday::ResourceNotFound
    false
  rescue Faraday::Response
    # We'll get an HTTP Status 403 when the User doesn't have access to create cards
    # or the access_token has expired.
    false
  end

  def sync_connection!
    result = find_and_verify_uphold_user

    case result
    when UpholdUser
      success = update(
        is_member: result.memberAt.present?,
        member_at: result.memberAt,
        status: result.status,
        uphold_id: result.id,
        country: result.country
      )
      create_uphold_cards if missing_card? && success
      success
    end
  end

  def update_site_banner_lookup!
    T.unsafe(publisher).update_site_banner_lookup!
  end

  # Internal: If the publisher previously had referral codes and then we will re-activate their referral codes.
  #
  # Returns nil
  def update_promo_status
    T.unsafe(publisher).update_promo_status!
  end

  def japanese_account?
    country == JAPAN
  end

  def currencies
    ["BAT", default_currency].uniq.compact
  end

  # Legacy methods

  def authorization_expires_at
    JSON.parse(uphold_access_parameters || "{}")&.fetch("expiration_time", nil)&.to_datetime
  end

  def authorization_expired?
    return true if authorization_expires_at.blank?
    authorization_expires_at.present? && authorization_expires_at < Time.zone.now
  end

  # V2 Flow methods. These should eventually go to the base class as
  # gemini connection uses the exact same flow
  def is_valid_connection?
    access_expiration_time.present? && refresh_token.present? && access_token.present?
  end

  def access_token_expired?
    access_expiration_time.present? && Time.now > T.unsafe(access_expiration_time)
  end

  def access_token
    JSON.parse(uphold_access_parameters || "{}")&.fetch("access_token", nil)
  end

  def refresh_token
    JSON.parse(uphold_access_parameters || "{}")&.fetch("refresh_token", nil)
  end

  def fetch_refresh_token
    refresh_token
  end

  # Uphold refresh token flow is also one time use.
  # We've gotta be so careful about all the places this gets called.
  # It's one reason I've had to go in and remove all these legacy methods.
  sig { params(blk: T.nilable(T.proc.bind(self).params(arg0: Oauth2::Errors::UnknownError).returns(Oauth2::Responses::ErrorResponse))).returns(T.any(UpholdConnection, ErrorResponse, BFailure)) }
  def refresh_authorization!(&blk)
    return self if is_valid_connection? && !access_token_expired?
    super
  end

  sig { override.params(refresh_token_response: RefreshTokenResponse).returns(UpholdConnection) }
  def update_access_tokens!(refresh_token_response)
    # https://sorbet.org/docs/tstruct#converting-structs-to-other-types
    authorization_hash = refresh_token_response.serialize
    expires_at = authorization_hash["expires_in"].to_i.seconds.from_now

    # Add to model so queries can be made.
    self.access_expiration_time = expires_at

    # Preserve for backwards compatibility
    authorization_hash["expiration_time"] = expires_at

    # Update with the latest Authorization
    # This is very much required but encrypted attr seems to throw rubocop for a loop
    self.uphold_access_parameters = JSON.dump(authorization_hash)
    save!

    self
  end

  sig { returns(Uphold::ConnectionClient) }
  def connection_client
    @_connection_client ||= Uphold::ConnectionClient.new(self)
  end

  # We will certainly want to reuse this to check
  # when a user's account has been flagged so
  # we need to handle not raising exceptions in that case.
  sig {
    returns(T.any(UpholdUser, UnverifiedConnectionError, FlaggedConnectionError, DuplicateConnectionError, WalletCreationError))
  }
  def find_and_verify_uphold_user
    result = connection_client.users.get

    case result

    when UpholdUser
      # Deny flagged or pending users
      if result.status != "ok"
        FlaggedConnectionError.new("Cannot create Uphold connection.  Please contact Uphold to review your account's status.")
      # Deny unverified wallets
      elsif UpholdConnection.strict_create && !result.memberAt.present?
        UnverifiedConnectionError.new("Cannot create Uphold connection. Please complete Uphold's account verification process and try again.")
      # Deny duplicates
      elsif UpholdConnection.strict_create && UpholdConnection.in_use?(result.id)
        if UpholdConnection.is_suspended?(result.id)
          result
        else
          DuplicateConnectionError.new("Could not establish Uphold connection. It looks like your Uphold account is already connected to another Brave Creators account. Your Uphold account can only be connected to one Brave Creators account at a time.")
        end
      else
        result
      end
    when Faraday::Response
      LogException.perform(result)
      WalletCreationError.new("Unable to connect to Uphold.  Please try again in a few minutes.")
    else
      T.absurd(result)
    end
  end

  sig { returns(UpholdUser) }
  def find_and_verify_uphold_user!
    result = find_and_verify_uphold_user

    case result
    when UpholdUser
      result
    else
      raise result
    end
  end

  sig { returns(UpholdCard) }
  def find_or_create_uphold_card!
    raise InsufficientScopeError.new("Cannot configure wallet") if !can_create_uphold_cards?

    begin
      result = Uphold::FindOrCreateCardService.build.call(self)
    rescue => e
      result = e
    end

    case result
    when UpholdCard
      result
    else
      LogException.perform("Uphold wallet creation failed for publisher #{publisher_id} with #{result}")
      raise WalletCreationError.new("Could not configure #{default_currency} deposits for Uphold")
    end
  end

  def has_deposit_capability?
    result = connection_client.users.get_capability("deposits")

    case result
    when UpholdUserCapability
      result.requirements.empty? && result.restrictions.empty?
    else
      false
    end
  end

  class << self
    include Uphold::Types
    include Oauth2::Responses
    include Oauth2::Errors

    def provider_name
      "Uphold"
    end

    def oauth2_config
      Oauth2::Config::Uphold
    end

    sig { override.params(publisher: Publisher, access_token_response: AccessTokenResponse).returns(UpholdConnection) }
    def create_new_connection!(publisher, access_token_response)
      access_expiration_time = access_token_response.expires_in.present? ? T.must(access_token_response.expires_in).seconds.from_now : nil

      # Do everything in a transaction so hopefully we begin tamping down data artifacts
      ActiveRecord::Base.transaction do
        # 1.) Cleanup artifacts in absence of any actual uniqueness verifications
        # We have so many empty connections
        UpholdConnection.where(publisher_id: publisher.id).delete_all

        # 2.) Set core params/token values.
        conn = UpholdConnection.new(
          publisher_id: publisher.id,
          uphold_access_parameters: access_token_response.serialize.to_json,
          access_expiration_time: access_expiration_time,
          uphold_verified: true,
          default_currency: "BAT",
          default_currency_confirmed_at: Time.now
        )

        if !conn.has_deposit_capability?
          raise CapabilityError.new("Uphold has placed additional requirements or restrictions on your account and we cannot create your connection at this time.  Please contact Uphold directly.")
        end

        # 3.) Pull data on existing user from uphold and set on model
        # Fail whole transaction if cannot be found
        user = conn.find_and_verify_uphold_user!

        # Sorbet is strict
        if user.memberAt.present?
          conn.member_at = Time.zone.parse(user.memberAt)
          conn.is_member = true
        else
          conn.is_member = false
        end

        # Wow.  This I haven't encountered before
        # The type annotations of the UpholdUser struct are different
        # from that of the model, so you have to cast the values
        # in order to assign them
        conn.status = T.must(user.status)
        conn.uphold_id = T.must(user.id)
        conn.country = user.country

        # 4.) Create the uphold "card" or wallet for the default currency in question.
        # Fail if we cannot
        result = conn.find_or_create_uphold_card!

        case result
        when UpholdCard
          # 5.) Save card id and write to disk
          conn.address = result.id
          conn.save!

          # 6.) Update publisher, fail if anything goes wrong
          #
          # If all succeeds we have everything we need for a valid UpholdConnection
          # on create.
          publisher.update!(selected_wallet_provider: conn)

          # Create whatever this report is, pulled out of the previous uphold connections controller
          UpholdStatusReport.find_or_create_by(publisher_id: publisher.id, uphold_id: conn.uphold_id).save!

          conn
        else
          T.absurd(result)
        end
      end
    end

    def in_use?(uphold_id)
      UpholdConnection.where(uphold_id: uphold_id).joins(:publisher).where.not(publisher: {name: PublisherStatusUpdate::DELETED, email: nil, pending_email: nil}).count > 0
    end

    # The constant is defined on the publisher model because this should be applicable to any connection provider, not just Uphold.
    def is_suspended?(uphold_id)
      Publisher.suspended.joins(:uphold_connection).where(uphold_connection: {uphold_id: uphold_id}).count >= ::Publisher::MAX_SUSPENSIONS
    end

    def encryption_key(key: Rails.application.secrets[:attr_encrypted_key])
      # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
      # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
      key.byteslice(0, 32)
    end
  end

  private

  def send_blocked_message
    SlackMessenger.new(message: "Publisher #{id} is blocked by Uphold and has just logged in. <!channel>", channel: SlackMessenger::ALERTS).perform
  end
end
