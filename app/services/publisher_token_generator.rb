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
    publisher.authentication_token = SecureRandom.hex(32)
    publisher.authentication_token_expires_at = Time.now + TOKEN_TTL
    publisher.save!
    publisher.authentication_token
  end
end
