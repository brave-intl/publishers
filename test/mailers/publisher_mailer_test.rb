require 'test_helper'

class PublisherMailerTest < ActionMailer::TestCase

  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  test "uphold_account_changed" do
    publisher = publishers(:default)
    email = PublisherMailer.uphold_account_changed(publisher)

    # # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to
  end

  test "wallet_not_connected" do
    publisher = publishers(:uphold_connected)
    email = PublisherMailer.wallet_not_connected(publisher)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to
  end

  test "wallet_not_connected raises error if publisher has address and is uphold_connected" do
    Rails.application.secrets[:api_eyeshade_offline] = false

    publisher = publishers(:uphold_connected)
    email = PublisherMailer.wallet_not_connected(publisher)

    wallet_response = {"wallet" => {"address" => "123ABC" }}.to_json
    stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
      to_return(status: 200, body: wallet_response, headers: {})

    assert_raises do
      email.deliver_now
    end
  end

  test "confirm_email_change" do
    publisher = publishers(:completed)
    publisher.pending_email = "alice-pending@verified.com"
    publisher.save

    email = PublisherMailer.confirm_email_change(publisher)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.pending_email], email.to
  end

  test "verify_email error is rescued if there is no send address" do
    publisher = publishers(:completed)
    publisher.pending_email = ""
    publisher.email = "alice_verified@default.org"
    publisher.save

    # verify error raised if no pending email
    assert_nothing_raised do
      # (Albert Wang): VerifyEmailEmailer should be tested but it simply runs the below statements
      PublisherTokenGenerator.new(publisher: publisher).perform
      PublisherMailer.verify_email(publisher).deliver_now
    end

    publisher.pending_email = "alice_new@default.org"
    publisher.save

    # verify nothing raised if pending email exists
    assert_nothing_raised do
      PublisherMailer.verify_email(publisher).deliver_now
    end
  end

  test "login_email verify_email verification_done and confirm_email_change raise unless token fresh" do
    publisher = publishers(:default)

    publisher.authentication_token = nil
    publisher.authentication_token_expires_at = 1.hour.ago

    assert_raise do PublisherMailer.login_email(publisher).deliver end
    assert_raise do PublisherMailer.verify_email(publisher).deliver end
    assert_raise do PublisherMailer.confirm_email_change(publisher).deliver end
    assert_raise do PublisherMailer.verification_done(publisher.channels.first).deliver end
  end
end
