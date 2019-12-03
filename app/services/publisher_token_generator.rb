# Generate a Publisher #authentication_token, which is a one time use token
# for creating a login session. They expire after 3 hours.
# @returns new authentication_token
class PublisherTokenGenerator < BaseService
  TOKEN_TTL = 3.hours

  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    user_authentication_token = UserAuthenticationToken.find_or_initialize_by(user_id: publisher.id)
    user_authentication_token.authentication_token = SecureRandom.hex(32)
    user_authentication_token.authentication_token_expires_at = Time.now + TOKEN_TTL
    user_authentication_token.save!
    user_authentication_token.authentication_token
  end
end
