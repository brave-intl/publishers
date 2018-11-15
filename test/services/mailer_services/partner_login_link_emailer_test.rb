require "test_helper"
require "webmock/minitest"

class PartnerLoginLinkEmailerTest < ActiveJob::TestCase
  test "sends one email and refreshes auth token" do
    partner = publishers(:partner)

    prev_auth_token = partner.authentication_token
    prev_auth_token_expires_at = partner.authentication_token_expires_at

    assert_enqueued_jobs(1) do
      MailerServices::PartnerLoginLinkEmailer.new(partner: partner).perform
    end

    assert_not_equal prev_auth_token, partner.authentication_token
    assert prev_auth_token_expires_at < partner.authentication_token_expires_at
  end
end
