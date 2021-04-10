require "test_helper"
require "webmock/minitest"
require "shared/mailer_test_helper"

# (Albert Wang): Because we disabled referrals, users can't create referrals for themselves
# The controller's create function only runs in tests and in development.
# Although it's unlikely, we retain this in case we need to turn back on the referral program.

module Publishers
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
      assert_equal publisher.may_create_referrals?, false
    end

    test "#create does nothing and renders _active if promo already enabled " do
      skip # Check comment at the root
      publisher = publishers(:completed)
      sign_in publisher

      # verify _over is rendered
      post promo_registrations_path
      assert_select("[data-test=promo-active]")

      # verify publisher has not enabled promo
      # assert_equal publisher.promo_enabled_2018q1, false
    end

    test "#create renders _activated_verified and enables promo for verfied publisher, sends email" do
      skip # Check comment at the root
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
      assert publisher.may_create_referrals?
    end

    test "#create redirects to #index if publisher promo enabled and renders _active and supports the new FeatureFlag" do
      skip # Check comment at the root
      publisher = publishers(:completed)
      publisher.save

      sign_in publisher

      # verify activate is loaded
      get promo_registrations_path
      assert_select("[data-test=promo-activate]")

      # enabled promo
      post promo_registrations_path
      follow_redirect!

      # verify _active is rendered
      assert_select("[data-test=promo-activated-verified]")

      # verify they have enabled the promo
      publisher.reload
      assert publisher.may_create_referrals?

      # verify active page is loaded
      get promo_registrations_path
      assert_select("[data-test=promo-active]")
    end

    test "all requests with no promo_token in params or publisher in the session redirect homepage" do
      skip # Check comment at the root
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
end
