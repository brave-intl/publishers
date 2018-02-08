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
    assert_select("[data-test=promo-active]")

    # verify publisher has not enabled promo
    # assert_equal publisher.promo_enabled_2018q1, false
  end

  test "#create activates the promo, renders _activated_verified and enables promo for verfied publisher, sends email" do
    publisher = publishers(:completed)
    sign_in publisher

    # verify promo-activated email is sent
    assert_difference("ActionMailer::Base.deliveries.count" , 1) do
      post promo_registrations_path
    end

    email = ActionMailer::Base.deliveries.last

    # verify email is sent to correct publisher
    assert email.to, publisher.email

    # verify the referral link sent matches the publisher's channel
    assert_email_body_matches(matcher: referral_url(publisher.channels.first.promo_registration.referral_code), email: email)

    # verify create is rendered
    assert_select("[data-test=promo-activated-verified]")

    # verify promo is enabled for publisher
    assert_equal publisher.promo_enabled_2018q1, true
  end

  test "#create activates the promo, renders _activated_unverified and enables promo for unverified publisher, sends email" do
    publisher = publishers(:default) # has one unverified channel
    sign_in publisher

    # verify no promo-activated email is sent
    assert_difference("ActionMailer::Base.deliveries.count" , 1) do
      post promo_registrations_path
    end

    email = ActionMailer::Base.deliveries.last

    # verify email is sent to correct publisher
    assert email.to, publisher.email

    # verify email has the "Login to Add Channel" call to action
    assert_email_body_matches(matcher: I18n.t("promo_mailer.promo_activated_2018q1_unverified.cta").to_s, email: email)

    # verify create is rendered
    assert_select("[data-test=promo-activated-unverified]")

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

  test "publisher can activate/visit promo without being signed in using promo token from email" do
    publisher = publishers(:completed)

    # ensure we use token, not session for promo auth
    sign_out publisher

    promo_token = PublisherPromoTokenGenerator.new(publisher: publisher).perform

    # verify promo token auth takes you to _activate page
    url = promo_registrations_path(promo_token: promo_token)
    get url
    assert_response 200
    assert_select("[data-test=promo-activate]")

    # verify the above does not enable the promo
    assert_equal publisher.promo_enabled_2018q1, false

    # verify promo auth allows promo activation, takes publisher to _activated_verified
    post url
    publisher.reload
    assert_equal publisher.promo_enabled_2018q1, true
    assert_select("[data-test=promo-activated-verified]")

    # verify promo auth allows users to view active page once authorized
    get url
    assert_select("[data-test=promo-active]")

    # verify publisher is not must reauth to visit dashboard
    get home_publishers_path(publisher)
    assert_response 401 # Unauthorized # TO DO: See screen this takes you to, ideally dashboard
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
