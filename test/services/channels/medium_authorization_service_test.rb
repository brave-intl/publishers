# typed: false
require "test_helper"

class MediumAuthorizationServiceTest < ActiveSupport::TestCase
  include Channels
  let(:schema) {
    {
      "provider" => "medium",
      "uid" => "1ec92d6f7dc96f3c95dfa0100d0bf03f36d2fe6b27a15b5c3061609866650d484",
      "info" => {
        "id" => "1ec92d6f7dc96f3c95dfa0100d0bf03f36d2fe6b27a15b5c3061609866650d484",
        "username" => "adamkirkwood",
        "name" => "Adam Kirkwood",
        "url" => "https://medium.com/@adamkirkwood",
        "imageUrl" => "https://cdn-images-1.medium.com/fit/c/200/200/0*lBXH3ieYv40OwIlo.jpeg"
      },
      "credentials" => {
        # FIXME: Obviously not right
        "token" => "...",
        "refresh_token" => "...",
        "expires_at" => "...",
        "expires" => "true"
      },
      "extra" => {

      }
    }
  }
  test "#build" do
    assert_instance_of(MediumAuthorizationService, MediumAuthorizationService.build)
  end

  test "#call" do
    assert MediumAuthorizationService.build.call(Types::OmniAuthHash.new(schema.symbolize_keys!))
  end
end
