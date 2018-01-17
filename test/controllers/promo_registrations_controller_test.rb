require "test_helper"
require "webmock/minitest"

class PromoRegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include PublishersHelper

  test "#index renders :activate if publisher hasn't activated, otherwise renders :active" do
    publisher = publishers(:completed)
    sign_in publisher

    # verify activate is rendered when promo inactive
    get promo_registrations_path
    assert_select("[data-test=promo-activate]")

    publisher.promo_enabled_2018q1 = true
    publisher.save

    # verify active is rendered when promo active
    get promo_registrations_path
    assert_select("[data-test=promo-active]")
  end

  test "#index renders :over if promo not running" do
    publisher = publishers(:completed)
    sign_in publisher

    # expire the promo
    PromoRegistrationsController.any_instance.stubs(:active_promo_id).returns("")

    # verify over is rendered
    get promo_registrations_path
    assert_select("[data-test=promo-over]")
  end

  test "#create activates the promo, renders :activated and enables promo for publisher" do
    publisher = publishers(:completed)
    sign_in publisher

    # verify activated is rendered
    post promo_registrations_path
    assert_select("[data-test=promo-activated]")

    # verify promo is enabled for publisher
    assert_equal publisher.promo_enabled_2018q1, true
  end

  test "#create does nothing and redirects to dashboard if promo not running" do
    publisher = publishers(:completed)
    sign_in publisher

    # expire the promo
    PromoRegistrationsController.any_instance.stubs(:active_promo_id).returns("")

    # verify :over is rendered
    post promo_registrations_path
    assert_select("[data-test=promo-over]")

    # verify publisher has not enabled promo
    assert_equal publisher.promo_enabled_2018q1, false
  end

  test "#create does not re-register channels with promos with service" do
    # TO DO
  end

  test "#create does not register unverified channels with promo service" do
    # TO DO
  end
end