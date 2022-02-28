# typed: true

module Channels
  class MediumAuthorizationService < BuilderBaseService
    extend T::Sig

    class Success < T::Struct
      const :value, T::Boolean
    end

    def self.build
      new
    end

    # I have this test object in here just to ensure that the ABC call method handles arbitrary types
    # I will remove it subsequently
    sig {
      override.params(auth_hash: Channels::Types::OmniAuthHash, test: T.nilable(String)).returns(T.any(Success, BFailure))
    }
    def call(auth_hash, test: nil)
      Success.new(value: true)
    end
  end
end
