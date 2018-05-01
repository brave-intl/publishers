require "test_helper"
require "webmock/minitest"

class VerifyEmailEmailerTest < ActiveJob::TestCase
  test "sends one email and refreshes auth token" do
    publisher = publishers(:completed)

    prev_auth_token = publisher.authentication_token
    prev_auth_token_expires_at = publisher.authentication_token_expires_at

    assert_enqueued_jobs(2) do
      MailerServices::VerifyEmailEmailer.new(publisher: publisher).perform
    end

    assert_not_equal prev_auth_token, publisher.authentication_token
    assert prev_auth_token_expires_at < publisher.authentication_token_expires_at
  end
end