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
    const :expires_in, Integer
    prop :refresh_token, T.nilable(String)
    prop :scope, T.nilable(String)
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
