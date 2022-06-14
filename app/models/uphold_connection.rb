# typed: true
# frozen_string_literal: true

class UpholdConnection < Oauth2::AuthorizationCodeBase
  class WalletCreationError < StandardError; end
  class UnverifiedConnectionError < WalletCreationError; end
  class DuplicateConnectionError < WalletCreationError; end
  class FlaggedConnectionError < WalletCreationError; end
  class InsufficientScopeError < WalletCreationError; end

  include WalletProviderProperties
  include Uphold::Types

  has_paper_trail only: [:is_member, :member_at, :uphold_id, :address, :status, :default_currency]

  UPHOLD_CODE_TIMEOUT = 5.minutes
  UPHOLD_ACCESS_PARAMS_TIMEOUT = 2.hours
  UPHOLD_CARD_LABEL = "Brave Rewards"

  # Snooze for the next ~ 80 years, this is what I consider forever from now :)
  FOREVER_DATE = DateTime.new(2100, 1, 1)

  USE_BROWSER = 1

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

  belongs_to :publisher

  has_many :uphold_connection_for_channels

  after_save :update_site_banner_lookup!, if: -> { T.bind(self, UpholdConnection).saved_change_to_attribute(:is_member) }
  after_save :update_promo_status, if: -> { T.unsafe(T.bind(self, UpholdConnection)).saved_change_to_attribute(:is_member) }

  # publishers that have access params that havent accepted by eyeshade
  # can be cleared after 2 hours
  scope :has_stale_uphold_access_parameters, -> {
    where.not(encrypted_uphold_access_parameters: nil)
      .where("updated_at < ?", UPHOLD_ACCESS_PARAMS_TIMEOUT.ago)
  }

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
      (uphold_access_parameters.blank? || scope.exclude?("cards:write") || status&.to_sym == UpholdAccountState::OLD_ACCESS_CREDENTIALS)
  end

  # Makes a remote HTTP call to Uphold to get more details
  # TODO should we actually call uphold_user?
  # FIXME: Remove the secondary refresher calls and the error handling
  # Simplifying this method causes tests to break across the suite because
  # of what mostly appear to be bad mocking.  Will need to revisit later.
  def uphold_details
    # This isn't necessary, it was a convoluted wrapper around UpholdClient.user
    # which is now explicitly called when it is needed.
    #
    # However for the sake of backwards compatibility I'm leaving... for the moment
    nil
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

  def username
    uphold_details&.username
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

  def wallet
    @wallet ||= publisher&.wallet
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
    ["BAT"]
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
    else
      nil
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
    []
  end

  def authorization_expires_at
    JSON.parse(uphold_access_parameters || "{}")&.fetch("expiration_time", nil)&.to_datetime
  end

  def authorization_expired?
    return true if authorization_expires_at.blank?
    authorization_expires_at.present? && authorization_expires_at < Time.zone.now
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
    uphold_access_parameters = JSON.dump(authorization_hash)
    save!

    self
  end

  sig { returns(Uphold::ConnectionClient) }
  def uphold_client
    @_uphold_client ||= Uphold::ConnectionClient.new(conn: self)
  end

  # We will certainly want to reuse this to check
  # when a user's account has been flagged so
  # we need to handle not raising exceptions in that case.
  sig { returns(T.any(UpholdUser, UnverifiedConnectionError, FlaggedConnectionError, DuplicateConnectionError, WalletCreationError
 )) }
  def find_and_verify_uphold_user
    result = uphold_client.users.get

    case result
    when UpholdUser
      # Deny unverified wallets
      if !result.memberAt.present?
        UnverifiedConnectionError.new("Cannot create Uphold connection. Please complete Uphold's account verification and try again.")
      # Deny flagged or pending users
      elsif result.status != "ok"
        FlaggedConnectionError.new("Cannot create Uphold connection.  Please contact Uphold to review your account's status.")
     # Deny duplicates
      elsif UpholdConnection.where(uphold_id: result.id).count > 0
        DuplicateConnectionError.new("Cannot create Uphold connection. This uphold account is already association with another Creator.")
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
    raise InsufficientScopeError if !can_create_uphold_cards?
    result = Uphold::FindOrCreateCardService.build.call(self)

    case result
    when UpholdCard
      result
    else
      LogException.perform(result)
      raise WalletCreationError.new("Could not configure #{default_currency} deposits for Uphold")
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

    # Note: I tried to put this in a service as it is appropriate there, but 
    # I've been struggling to figure out the annotation for an abstract method that takes arbitrary args/kwargs
    # 
    # The current BuilderBaseService.call method only allows 1 positional required param.
    # There's too much to deal with here to get bogged down on that right now.
    sig { override.params(publisher: Publisher, access_token_response: AccessTokenResponse).returns(UpholdConnection) }
    def create_new_connection!(publisher, access_token_response)
      access_expiration_time = access_token_response.expires_in.present? ? T.must(access_token_response.expires_in).seconds.from_now : nil

      # Do everything in a transaction so hopefully we begin tamping down data artifacts
      ActiveRecord::Base.transaction do
        # 1.) Cleanup artifacts in absence of any actual uniqueness verifications
        # We have so many empty connections
        UpholdConnection.where(publisher_id: T.unsafe(publisher).id).delete_all

        # 2.) Set core params/token values
        conn = UpholdConnection.new(
          publisher_id: T.unsafe(publisher).id,
          uphold_access_parameters: access_token_response.serialize.to_json,
          access_expiration_time: access_expiration_time,
          uphold_verified: true,
          default_currency: "BAT",
          default_currency_confirmed_at: Time.now
        )

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
          T.unsafe(publisher).update!(selected_wallet_provider: conn)

          conn
        else
          T.absurd(result)
        end
      end
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
