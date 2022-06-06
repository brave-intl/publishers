module Oauth2::Responses
  # Error Rresponse: https://datatracker.ietf.org/doc/html/rfc6749#section-4.1.2.1
  class ErrorResponse < T::Struct
    const :error, String
    prop :error_description, T.nilable(String)
    prop :error_uri, T.nilable(String)
  end

  # Access Token Response:   https://datatracker.ietf.org/doc/html/rfc6749#section-4.4.3
  class AccessTokenResponse < T::Struct
    const :token_type, String
    const :access_token, String
    const :expires_in, T.nilable(Integer)
    prop :refresh_token, T.nilable(String)
    prop :scope, T.nilable(String)
  end

  # Bitflyer Access Token Response: Slight variation of to spec, but includes account hash
  # which is the unique identifier for Bitflyer and is returned in the access token response.
  class BitflyerAccessTokenResponse < T::Struct
    const :token_type, String
    const :access_token, String
    const :expires_in, T.nilable(Integer)
    prop :refresh_token, T.nilable(String)
    prop :scope, T.nilable(String)
    const :account_hash, String
  end

  # Refresh Token Response: https://datatracker.ietf.org/doc/html/rfc6749#section-4.3.3
  class RefreshTokenResponse < T::Struct
    const :token_type, String
    const :access_token, String
    const :expires_in, Integer
    const :refresh_token, String
    prop :scope, T.nilable(String)
  end
end
