# typed: true

module Oauth2ProviderProperties
  include Oauth2::Structs
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers
  abstract!

  sig { abstract.returns(String) }
  def token_url
  end

  sig { abstract.returns(String) }
  def client_id
  end

  sig { abstract.returns(String) }
  def client_secret
  end

  sig { abstract.returns(T.nilable(String)) }
  def refresh_token
  end

  sig { abstract.params(refresh_token_response: RefreshTokenResponse).returns(T.self_type) }
  def update_access_tokens!(refresh_token_response)
  end

  sig { abstract.returns(T.self_type) }
  def record_refresh_failure!
  end
end
