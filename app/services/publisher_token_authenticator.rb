# Authenticate a Publisher by #authentication_token, which are consumed on use
# and expires after 3 hours. New ones can be sent to your email.
class PublisherTokenAuthenticator < BaseService
  attr_reader :publisher, :token, :confirm_email

  def initialize(publisher:, token:, confirm_email:)
    @publisher = publisher
    @token = token
    @confirm_email = confirm_email
  end

  # Note: If the token was valid, this consumes it.
  def perform
    if publisher.authentication_token.blank?
      return false
    end
    if publisher.authentication_token_expires_at.blank? || (Time.now > publisher.authentication_token_expires_at)
      return false
    end
    result = ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(token),
      ::Digest::SHA256.hexdigest(publisher.user_authentication_token.authentication_token)
    )
    if result
      pending_email = publisher.pending_email
      if pending_email.present?
        if publisher.email.blank?
          publisher.email = pending_email
        elsif confirm_email.present? && confirm_email == pending_email
          publisher.email = pending_email
        end
        publisher.pending_email = nil
      end
      publisher.user_authentication_token.update(authentication_token: nil)
      publisher.save!
    end
    result
  end
end
