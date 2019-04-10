require "test_helper"
require "webmock/minitest"

class ConfirmEmailChangeEmailerTest < ActiveJob::TestCase
  test "sends two emails and refreshes token" do
    publisher = publishers(:completed)
    PublisherTokenGenerator.new(publisher: publisher).perform
    prev_auth_token = publisher.authentication_token
    prev_auth_token_expires_at = publisher.authentication_token_expires_at

    assert_enqueued_jobs(3) do
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: publisher).perform
    end

    publisher.reload
    assert_not_equal prev_auth_token, publisher.authentication_token
    assert prev_auth_token_expires_at < publisher.authentication_token_expires_at
  end
end
