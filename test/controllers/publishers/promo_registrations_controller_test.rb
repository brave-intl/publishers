require "test_helper"
require "webmock/minitest"
require "shared/mailer_test_helper"

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
  end
end
