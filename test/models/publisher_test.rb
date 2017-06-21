require "test_helper"
require "shared/mailer_test_helper"

class PublisherTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper

  test "sends an email after bitcoin address change" do
    perform_enqueued_jobs do
      publisher = publishers(:verified)
      publisher.bitcoin_address = "1XPTgDRhN8RFnzniWCddobD9iKZatrvH4"
      publisher.save!
      publisher.bitcoin_address = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
      publisher.save!
      email = ActionMailer::Base.deliveries.find do |message|
        message.to.first == publisher.email
      end
      assert_not_nil(email)
      assert_email_body_matches(matcher: publisher.bitcoin_address, email: email)
    end
  end
end
