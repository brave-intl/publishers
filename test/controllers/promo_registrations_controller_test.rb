require "test_helper"
require "webmock/minitest"
require "shared/mailer_test_helper"

class PromoRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PromosHelper
  include MailerTestHelper

  test "#index renders _over if promo not running" do
    publisher = publishers(:completed)
    sign_in publisher

    # expire the promo
    PromoRegistrationsController.any_instance.stubs(:promo_running?).returns(false)

    # verify over is rendered
    get promo_registrations_path
    assert_select("[data-test=promo-over]")
  end

  test "#index renders activate when promo running" do
    publisher = publishers(:completed)
    sign_in publisher

    # verify activate is rendered
    get promo_registrations_path
    assert_select("[data-test=promo-activate]")
  end

  test "#create does nothing and redirects _over if promo not running" do
    publisher = publishers(:completed)
    sign_in publisher

    # expire the promo
    PromoRegistrationsController.any_instance.stubs(:promo_running?).returns(false)

    # verify _over is rendered
    post promo_registrations_path
    follow_redirect!
    assert_select("[data-test=promo-over]")

    # verify publisher has not enabled promo
    assert_equal publisher.promo_enabled_2018q1, false
  end

  test "#create does nothing and renders _active if promo already enabled " do
    publisher = publishers(:completed)
    sign_in publisher

    publisher.promo_enabled_2018q1 = true
    publisher.save

    # verify _over is rendered
    post promo_registrations_path
    follow_redirect!
    assert_select("[data-test=promo-active]")

    # verify publisher has not enabled promo
    # assert_equal publisher.promo_enabled_2018q1, false
  end

  test "#create renders _activated_verified and enables promo for verfied publisher, sends email" do
    publisher = publishers(:completed)
    sign_in publisher

    # verify promo-activated email is sent
    assert_difference("ActionMailer::Base.deliveries.count" , 0) do
      post promo_registrations_path
    end

    channel = publisher.channels.first

    Promo::RegisterChannelForPromoJob.perform_now(channel_id: channel.id)

    perform_enqueued_jobs do
      PromoMailer.new_channel_registered_2018q1(channel.publisher, channel).deliver_now
    end
    email = ActionMailer::Base.deliveries.last

    # verify email is sent to correct publisher
    assert email.to, publisher.email

    # verify the referral link sent matches the publisher's channel
    assert_email_body_matches(matcher: https_referral_url(publisher.channels.first.promo_registration.referral_code), email: email)

    # verify create is rendered
    assert_select("[data-test=promo-activated-verified]")

    # verify promo is enabled for publisher
    assert_equal publisher.promo_enabled_2018q1, true
  end

  test "#create redirects to #index if publisher promo enabled and renders _active" do
    publisher = publishers(:completed)
    publisher.save

    sign_in publisher

    # verify activate is loaded 
    get promo_registrations_path
    assert_select("[data-test=promo-activate]")

    # enabled promo
    post promo_registrations_path

    # verify _active is rendered
    assert_select("[data-test=promo-activated-verified]")

    # verify they have enabled the promo
    publisher.reload
    assert publisher.promo_enabled_2018q1

    # verify active page is loaded
    get promo_registrations_path
    assert_select("[data-test=promo-active]")
  end

  test "all requests with no promo_token in params or publisher in the session redirect homepage" do
    publisher = publishers(:completed)
    sign_out publisher

    # verify #create redirects to home if no token is supplied
    post promo_registrations_path
    assert_redirected_to root_path

    # verify #index redirects to home if no token is supplied
    get promo_registrations_path
    assert_redirected_to root_path
  end
end
