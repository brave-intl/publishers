# typed: true

class Oauth2::AuthorizationCodeBase < ApplicationRecord
  self.abstract_class = true
  include Oauth2::Responses
  include Oauth2::Errors
  extend T::Sig
  extend T::Helpers

  TYPES = T.type_alias { T.any(Oauth2::AuthorizationCodeBase, ErrorResponse, BFailure) }
  abstract!

  class << self
    extend T::Helpers
    extend T::Sig

    abstract!

    # Along with the instance methods, the primary interface
    # for using the Oauth2 client logic is the implementation
    # of a class that inherits from Oauth2::Config::AuthorizationCode
    #
    # and the definition of this method in the inheriting class.
    sig { abstract.returns(T.class_of(Oauth2::Config::AuthorizationCode)) }
    def oauth2_config
    end

    sig { returns(Oauth2::AuthorizationCodeClient) }
    def oauth2_client
      @_oauth_client ||= Oauth2::AuthorizationCodeClient.new(oauth2_config)
    end

    sig { abstract.params(publisher: Publisher, access_token_response: Oauth2::Responses::AccessTokenResponse).returns(Oauth2::AuthorizationCodeBase) }
    def create_new_connection!(publisher, access_token_response)
    end

    def state_value!
      SecureRandom.hex(64).to_s
    end
  end

  # Unique name to prevent collisions with existing methods
  sig { abstract.returns(T.nilable(String)) }
  def fetch_refresh_token
  end

  # Unique name to prevent collisions with existing methods
  sig { abstract.params(refresh_token_response: Oauth2::Responses::RefreshTokenResponse).returns(Oauth2::AuthorizationCodeBase) }
  def update_access_tokens!(refresh_token_response)
  end

  # Primary refresher implementation.  Shareable across all connections, simply requires the abstract methods
  # above in order to function.
  #
  # Note: optional block syntax in sorbet is obviously a bit painful, but this is how to do it.
  #
  # In human form this reads: "refresh_authorization! can take an optional block param that accepts an UnknownError as the first argument
  # and returns an ErrorResponse, while refresh_authorization! only returns TYPES.
  sig { params(blk: T.nilable(T.proc.bind(self).params(arg0: Oauth2::Errors::UnknownError).returns(Oauth2::Responses::ErrorResponse))).returns(TYPES) }
  def refresh_authorization!(&blk)
    if respond_to?(:oauth_refresh_failed) && send(:oauth_refresh_failed)
      return BFailure.new(errors: ["Connection refresh has already failed"])
    end

    refresh_token = fetch_refresh_token

    if refresh_token.nil?
      record_refresh_failure!
      return BFailure.new(errors: ["Cannot refresh without refresh token"])
    end

    # When we upgrade to rails 7, transaction blocks will silently roll back when either return or raise is called
    result = T.let(nil, T.nilable(T.any(Oauth2::Responses::RefreshTokenResponse, Oauth2::Errors::UnknownError, Oauth2::Responses::ErrorResponse)))
    T.must(with_lock do
      result = self.class.oauth2_client.refresh_token(refresh_token)
      result.is_a?(RefreshTokenResponse) ? update_access_tokens!(result) : record_refresh_failure!
    end)

    case result
    when RefreshTokenResponse
      self
    when ErrorResponse
      result
    when UnknownError
      if blk
        yield result
      else
        raise result
      end
    when nil
      # It technically shouldn't be nil, but Sorbet complained.  If the lock transaction were to be
      # rolled back without raising an error, just return the connection
      self
    else
      T.absurd(result)
    end
  end

  # We can reuse this method for all three cases because we added it at the same time.
  sig { returns(T.self_type) }
  def record_refresh_failure!
    update!(oauth_refresh_failed: true)
    self
  end

  sig { returns(T.self_type) }
  def record_refresh_failure_notification!
    update!(oauth_failure_email_sent: true)
    self
  end

  # I don't think this is really appropriate for this model so it should be moved out later
  # but I'm running into issues with sorbet and concerns/relations with the wallet_provider_properties
  # so I'm just going to ensure the interface exists for now and move on
  #
  # TODO: Abstract this to proper context
  sig { abstract.returns(T.untyped) }
  def sync_connection!
  end

  # TODO: Abstract this to proper context
  sig { abstract.returns(String) }
  def self.provider_name
  end
end
