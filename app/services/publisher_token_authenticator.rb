# typed: true
# Authenticate a Publisher by #authentication_token, which are consumed on use
# and expires after 3 hours. New ones can be sent to your email.
class PublisherTokenAuthenticator < BaseService
  attr_reader :publisher, :token

  def initialize(publisher:, token:)
    @publisher = publisher
    @token = token
  end

  # Note: If the token was valid, this consumes it.
  def perform(consume: true)
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
      publisher.user_authentication_token.update(authentication_token: nil) if consume
    end
    result
  end
end
