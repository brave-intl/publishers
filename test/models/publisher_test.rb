require "test_helper"
require "shared/mailer_test_helper"

class PublisherTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper

  test "uphold_code is only valid without uphold_access_parameters" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    assert publisher.valid?

    publisher.uphold_access_parameters = "bar"
    refute publisher.valid?
    assert_equal [:uphold_code], publisher.errors.keys
  end
end
