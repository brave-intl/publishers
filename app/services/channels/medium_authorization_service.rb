# typed: true

module Channels
  class MediumAuthorizationService < BuilderBaseService
    extend T::Sig

    def self.build
      new
    end

    sig { override.params(auth_hash: T::Hash[String, T.untyped]).returns(BServiceResult) }
    def call(auth_hash: {})
      pass(auth_hash)
    end
  end
end
