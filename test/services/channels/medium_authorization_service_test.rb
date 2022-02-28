# typed: false
require "test_helper"

class MediumAuthorizationServiceTest < ActiveSupport::TestCase
  include Channels

  test "#build" do
    assert_instance_of(MediumAuthorizationService, MediumAuthorizationService.build)
  end

  test "#call" do
    assert MediumAuthorizationService.build.call(auth_hash: {})
  end
end
