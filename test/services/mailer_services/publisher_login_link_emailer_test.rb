require "test_helper"
require "webmock/minitest"

class PublisherLoginLinkEmailerTest < ActiveJob::TestCase
  test "sends one email and refreshes auth token" do
    publisher = publishers(:completed)

    PublisherTokenGenerator.new(publisher: publisher).perform
    prev_auth_token = publisher.authentication_token
    prev_auth_token_expires_at = publisher.authentication_token_expires_at

    PublisherTokenGenerator.new(publisher: publisher).perform
    assert_enqueued_jobs(1) do
      MailerServices::PublisherLoginLinkEmailer.new(publisher: publisher).perform
    end

    publisher.reload
    assert_not_equal prev_auth_token, publisher.authentication_token
    assert prev_auth_token_expires_at < publisher.authentication_token_expires_at
  end
end
