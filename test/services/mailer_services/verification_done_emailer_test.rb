# typed: false
require "test_helper"
require "webmock/minitest"

class VerificationDoneEmailerTest < ActiveJob::TestCase
  test "sends one email and refreshes auth token" do
    publisher = publishers(:completed)

    prev_auth_token = publisher.authentication_token
    prev_auth_token_expires_at = publisher.authentication_token_expires_at

    assert_enqueued_jobs(2) do
      MailerServices::VerificationDoneEmailer.new(verified_channel: publisher.channels.first).perform
    end

    publisher.reload
    assert_not_equal prev_auth_token, publisher.authentication_token
    assert_not_equal prev_auth_token_expires_at, publisher.authentication_token_expires_at
  end
end
