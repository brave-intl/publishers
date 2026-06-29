# typed: true

module Channels
  class MediumAuthorizationService < BuilderBaseService
    Success = Struct.new(:value)
    def self.build
      new
    end

    def call(auth_hash, test: nil)
      Success.new(value: true)
    end
  end
end
