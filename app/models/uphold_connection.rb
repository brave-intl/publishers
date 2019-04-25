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

  # uphold_access_parameters should be cleared once uphold_verified has been set
  # (see `verify_uphold` method below)
  validates :uphold_access_parameters, absence: true, if: -> { uphold_verified? }

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
  # It is used to navigate to Uphold, therefore on GET request this state token must be there.
  def prepare_uphold_state_token
    return if uphold_state_token.present?
    self.uphold_state_token = SecureRandom.hex(64).to_s
    save!
  end

  def receive_uphold_code(code)
    self.uphold_state_token = nil
    self.uphold_code = code
    self.uphold_access_parameters = nil
    self.uphold_verified = false
    save!
  end

  def verify_uphold
    self.uphold_state_token = nil
    self.uphold_code = nil
    self.uphold_access_parameters = nil
    self.uphold_verified = true
    save!
  end

  def disconnect_uphold
    self.uphold_code = nil
    self.uphold_access_parameters = nil
    self.uphold_verified = false
    save!
  end

  def uphold_reauthorization_needed?
    uphold_verified? &&
      wallet.present? &&
      ['re-authorize', 'authorize'].include?(wallet.action)
  end

  def uphold_status
    uphold_account_status = wallet&.uphold_account_status&.to_sym

    send_blocked_message if uphold_account_status == UpholdAccountState::BLOCKED

    if uphold_account_status == UpholdAccountState::RESTRICTED
      UpholdAccountState::RESTRICTED
    elsif uphold_reauthorization_needed?
      UpholdAccountState::REAUTHORIZATION_NEEDED
    elsif uphold_verified? && wallet&.not_a_member?
      UpholdAccountState::RESTRICTED
    elsif uphold_verified? && wallet&.is_a_member?
      UpholdAccountState::VERIFIED
    elsif uphold_access_parameters.present?
      :access_parameters_acquired
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
      wallet.present? &&
      wallet.authorized? &&
      wallet.scope &&
      wallet.scope.include?("cards:write") &&
      !publisher.excluded_from_payout
  end

  def wallet
    @wallet ||= publisher&.wallet
  end

  def encryption_key
    # Truncating the key due to legacy OpenSSL truncating values to 32 bytes.
    # New implementations should use [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
    Rails.application.secrets[:attr_encrypted_key].byteslice(0, 32)
  end

  private

  def send_blocked_message
    SlackMessenger.new(message: "Publisher #{id} is blocked by Uphold and has just logged in. <!channel>").perform
  end
end
