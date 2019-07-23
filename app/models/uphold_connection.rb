# frozen_string_literal: true

class UpholdConnection < ActiveRecord::Base
  UPHOLD_CODE_TIMEOUT = 5.minutes
  UPHOLD_ACCESS_PARAMS_TIMEOUT = 2.hours

  attr_encrypted :uphold_code, key: :encryption_key
  attr_encrypted :uphold_access_parameters, key: :encryption_key

  class UpholdAccountState
    REAUTHORIZATION_NEEDED      = :reauthorization_needed
    VERIFIED                    = :verified
    ACCESS_PARAMETERS_ACQUIRED  = :access_parameters_acquired
    CODE_ACQUIRED               = :code_acquired
    UNCONNECTED                 = :unconnected
    # (Albert Wang): Consider adding refactoring all of the above states as they
    # aren't valid states: https://uphold.com/en/developer/api/documentation/#user-object
    RESTRICTED      = :restricted
    BLOCKED         = :blocked
  end

  belongs_to :publisher

  # uphold_code is an intermediate step to acquiring uphold_access_parameters
  # and should be cleared once it has been used to get uphold_access_parameters
  validates :uphold_code, absence: true, if: -> { uphold_access_parameters.present? || uphold_verified? }

  # publishers that have uphold codes that have been sitting for five minutes
  # can be cleared if publishers do not create wallet within 5 minute window
  scope :has_stale_uphold_code, -> {
    where.not(encrypted_uphold_code: nil).
      where("updated_at < ?", UPHOLD_CODE_TIMEOUT.ago)
  }

  # publishers that have access params that havent accepted by eyeshade
  # can be cleared after 2 hours
  scope :has_stale_uphold_access_parameters, -> {
    where.not(encrypted_uphold_access_parameters: nil).
      where("updated_at < ?", UPHOLD_ACCESS_PARAMS_TIMEOUT.ago)
  }

  # This state token is generated and must be unique when connecting to uphold.
  def prepare_uphold_state_token
    self.uphold_state_token = SecureRandom.hex(64).to_s
    save!
  end

  def scope
    JSON.parse(uphold_access_parameters)['scope']
  end

  def receive_uphold_code(code)
    update(
      uphold_code: code,
      uphold_state_token: nil,
      uphold_access_parameters: nil,
      uphold_verified: false,
    )
  end

  def disconnect_uphold
    update(
      address: nil,
      is_member: false,
      status: nil,
      uphold_id: nil,
      uphold_code: nil,
      uphold_access_parameters: nil,
      uphold_verified: false,
      default_currency_confirmed_at: nil,
      default_currency: nil,
    )
  end

  def uphold_reauthorization_needed?
    # TODO Let's make sure that if we can't access the user's information then we set uphold_verified? to false
    # Perhaps through a rescue on 401

    uphold_verified? && uphold_access_parameters.present? && uphold_details.nil?
  end

  # Makes a remote HTTP call to Uphold to get more details
  # TODO should we actually call uphold_user?

  def uphold_client
    @uphold_client ||= Uphold::Client.new
  end

  def uphold_details
    @user ||= uphold_client.user.find(self)
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
    elsif uphold_code.present?
      :code_acquired
    else
      UpholdAccountState::UNCONNECTED
    end
  end

  def uphold_processing?
    uphold_access_parameters.present? || uphold_code.present?
  end

  def can_create_uphold_cards?
    uphold_verified? &&
      uphold_access_parameters.present? &&
      scope.include?("cards:write") &&
      !publisher.excluded_from_payout
  end

  def wallet
    @wallet ||= publisher&.wallet
  end

  def create_uphold_card_for_default_currency
    CreateUpholdCardsJob.perform_now(uphold_connection: self)
  end

  def missing_card?
    default_currency_confirmed_at.present? && address.blank?
  end

  def sync_from_uphold!
    update(
      is_member: uphold_details.memberAt.present?,
      status: uphold_details.status,
      uphold_id: uphold_details.id
    )
  end

  def encryption_key
    # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
    # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
    Rails.application.secrets[:attr_encrypted_key].byteslice(0, 32)
  end

  private

  def send_blocked_message
    SlackMessenger.new(message: "Publisher #{id} is blocked by Uphold and has just logged in. <!channel>", channel: SlackMessenger::ALERTS).perform
  end
end
