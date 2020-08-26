# frozen_string_literal: true

class GeminiConnection < ApplicationRecord
  belongs_to :publisher

  validates :recipient_id, uniqueness: true, allow_blank: true

  attr_encrypted :access_token, :refresh_token, key: :encryption_key

  def prepare_state_token!
    update(state_token: SecureRandom.hex(64).to_s)
  end

  def payable?
    is_verified? && status == "Active"
  end

  def verify_url
    "#{Rails.application.config.services.gemini[:oauth_uri]}/settings/profile"
  end

  def access_token_expired?
    access_expiration_time.present? && Time.now > access_expiration_time
  end

  # Makes a request to the Gemini API to refresh the current access_token
  def refresh_authorization!
    # Ensure we have an refresh_token.
    return if refresh_token.blank?

    authorization = Gemini::Auth.refresh(token: refresh_token)

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

  private

  def encryption_key
    [Rails.application.secrets[:attr_encrypted_key]].pack("H*")
  end
end
