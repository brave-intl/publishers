module Oauth2::Responses
  # Error Rresponse: https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2.1
  ErrorResponse = Struct.new(
    :error,
    :error_description,
    :error_uri,
    keyword_init: true
  )

  # Access Token Response:   https://datatracker.ietf.org/doc/html/rfc6749#section-4.4.3
  AccessTokenResponse = Struct.new(
    :token_type,
    :access_token,
    :expires_in,
    :refresh_token,
    :scope,
    keyword_init: true
  )

  # Bitflyer Access Token Response: Slight variation of to spec, but includes account hash
  # which is the unique identifier for Bitflyer and is returned in the access token response.
  BitflyerAccessTokenResponse = Struct.new(
    :token_type,
    :access_token,
    :expires_in,
    :refresh_token,
    :scope,
    :account_hash,
    keyword_init: true
  )

  # Refresh Token Response: https://datatracker.ietf.org/doc/html/rfc6749#section-4.3.3
  RefreshTokenResponse = Struct.new(
    :token_type,
    :access_token,
    :expires_in,
    :refresh_token,
    :scope,
    keyword_init: true
  )
end
