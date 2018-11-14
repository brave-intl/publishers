# Generate a Partner #authentication_token, which is a one time use token
# for creating a login session. They expire after 3 hours.
# @returns new authentication_token
class PartnerTokenGenerator < BaseService
  TOKEN_TTL = 1.month

  attr_reader :partner

  def initialize(partner:)
    @partner = partner
  end

  def perform
    partner.authentication_token = SecureRandom.hex(32)
    partner.authentication_token_expires_at = Time.now + TOKEN_TTL
    partner.save!
    partner.authentication_token
  end
end
