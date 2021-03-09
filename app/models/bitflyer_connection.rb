# frozen_string_literal: true

class BitflyerConnection < ApplicationRecord
  SUPPORTED_CURRENCIES = ["BAT", "USD", "BTC", "ETH"].freeze
  JAPAN = "JP"

  belongs_to :publisher
  attr_encrypted :access_token, :refresh_token, key: :encryption_key
  validates :recipient_id, uniqueness: true, allow_blank: true
  validates :default_currency, inclusion: { in: SUPPORTED_CURRENCIES }, allow_nil: true
  after_destroy :selected_wallet_provider

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

  # Makes a request to the Bitflyer API to refresh the current access_token
  def refresh_authorization!
    # Ensure we have an refresh_token.
    return if refresh_token.blank?

    authorization = Bitflyer::Auth.refresh(token: refresh_token)

    # Update with the latest Authorization
    update!(
      access_token: authorization.access_token,
      refresh_token: authorization.refresh_token,
      expires_in: authorization.expires_in,
      access_expiration_time: authorization.expires_in.seconds.from_now
    )
    # Reload the model so consumers will have the most up to date information.
    reload
  end

  def sync_connection!
    return if access_token.blank?

    # If our access token has expired then we should refresh.
    if access_token_expired?
      refresh_authorization!
    end

    users = Bitflyer::Account.find(token: access_token).users
    user = users.find { |u| u.is_verified && u.status == 'Active' }

    # If we couldn't find a verified account we'll take the first user.
    user ||= users.first

    update(
      display_name: user.name,
      status: user.status,
      country: user.country_code,
      is_verified: user.is_verified,
    )

    # Users aren't able to create a recipient id if they are not fully verified
    if payable?
      recipient = Bitflyer::RecipientId.find_or_create(token: access_token)
      update(recipient_id: recipient.recipient_id)
    end
  end

  private

  def selected_wallet_provider
    return unless publisher.selected_wallet_provider.id == id
    publisher.update(selected_wallet_provider: nil)
  end

  def encryption_key
    [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
  end
end
