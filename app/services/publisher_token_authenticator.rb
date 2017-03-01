# Authenticate a Publisher by #authentication_token, which are consumed on use
# and expires after 3 hours. New ones can be sent to your email.
class PublisherTokenAuthenticator
  attr_reader :publisher, :token

  def initialize(publisher:, token:)
    @publisher = publisher
    @token = token
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
      ::Digest::SHA256.hexdigest(publisher.authentication_token)
    )
    if result
      publisher.authentication_token = nil
      publisher.save!
    end
    result
  end
end
