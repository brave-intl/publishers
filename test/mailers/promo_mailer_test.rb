require 'test_helper'
require "shared/mailer_test_helper"

class PromoMailerTest < ActionMailer::TestCase
  include PromosHelper
  include MailerTestHelper
  include Rails.application.routes.url_helpers

  test "activate_promo_2018q1" do
    publisher = publishers(:default)
    publisher.promo_token_2018q1 = "promo auth token 2018q1"
    publisher.save

    email = PromoMailer.activate_promo_2018q1(publisher)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to

    promo_token = publisher.promo_token_2018q1
    expected_promo_auth_url = promo_registrations_url(promo_token: promo_token, host: "www.example.com")
    
    assert_email_body_matches(matcher: expected_promo_auth_url, email: email)
  end

  test "promo_activated_2018q1_verified" do
    publisher = publishers(:default)
    channel = publisher.channels.first

    referral_code = "BATS-321"
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: "free-bats-2018q1", referral_code: referral_code)
    promo_registration.save!
    promo_enabled_channels = publisher.channels.joins(:promo_registration)

    email = PromoMailer.promo_activated_2018q1_verified(publisher, promo_enabled_channels)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to

    referral_link = human_referral_url(referral_code)
    
    assert_email_body_matches(matcher: referral_link, email: email)
  end

  test "promo_activated_2018q1_unverified" do
    publisher = publishers(:default)
    email = PromoMailer.promo_activated_2018q1_unverified(publisher)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['brave-publishers@localhost.local'], email.from
    assert_equal [publisher.email], email.to
  end

  test "new_channel_registered_2018q1" do
    publisher = publishers(:completed)
    channel = publisher.channels.first

    referral_code = "BATS-321"
    promo_registration = PromoRegistration.new(channel_id: channel.id, promo_id: "free-bats-2018q1", referral_code: referral_code)
    promo_registration.save!

    email = PromoMailer.new_channel_registered_2018q1(publisher, channel)

    assert_emails 1 do
      email.deliver_now
    end

    referral_link = human_referral_url(referral_code)
    
    assert_email_body_matches(matcher: referral_link, email: email)  end
end
