# typed: true

class Oauth2RefresherService < BuilderBaseService
  extend T::Sig
  include Oauth2
  include Oauth2::Structs

  class Success < T::Struct
    const :connection, UpholdConnection
  end

  def self.build
    new
  end

  sig { override.params(connection: UpholdConnection).returns(T.any(Oauth2RefresherService::Success, BFailure)) }
  def call(connection)
    result = Oauth2::ClientCredentials.new(
      client_id: connection.client_id,
      client_secret: connection.client_secret,
      token_url: connection.token_url
    )
      .refresh_token(connection.refresh_token)

    case result
    when RefreshTokenResponse
      Success.new(connection: connection.update_access_tokens!(result))
    when ErrorResponse
      connection.record_refresh_failure!
      BFailure.new(errors: [result.error])
    else
      T.absurd(result)
    end
  end
end
