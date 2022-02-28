# typed: true

module Channels
  class MediumAuthorizationService < BuilderBaseService
    extend T::Sig

    class Success < T::Struct
      const :auth_hash, T::Hash[String, T.untyped]
    end

    def self.build
      new
    end

    sig { override.params(auth_hash: T::Hash[String, T.untyped]).returns(T.any(Success, BFailure)) }
    def call(auth_hash: {})
      Success.new(auth_hash: auth_hash)
    end
  end
end
