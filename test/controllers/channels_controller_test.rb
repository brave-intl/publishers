require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class ChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PublishersHelper

  test "delete removes a channel and associated details" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)
    sign_in publisher
    assert_difference("publisher.channels.count", -1) do
      assert_difference("SiteChannelDetails.count", -1) do
        assert_enqueued_jobs 1 do
          delete channel_path(channel), headers: { 'HTTP_ACCEPT' => "application/json" }
          assert_response 204
        end
      end
    end
  end

  test "delete does not remove a channel and associated details if channel does not belong to publisher" do
    publisher = publishers(:small_media_group)
    channel = channels(:global_verified)
    sign_in publisher
    assert_difference("publisher.channels.count", 0) do
      assert_difference("SiteChannelDetails.count", 0) do
        delete channel_path(channel), headers: { 'HTTP_ACCEPT' => "application/json" }
        assert_response 302
      end
    end
  end

  test "delete removes a channel even if promo is enabled" do
    publisher = publishers(:small_media_group)
    channel = channels(:global_verified)
    sign_in publisher

    post promo_registrations_path

    assert_not_nil publisher.channels.first.promo_registration.referral_code

    assert_difference("publisher.channels.count", 0) do
      assert_difference("SiteChannelDetails.count", 0) do
        delete channel_path(channel), headers: { 'HTTP_ACCEPT' => "application/json" }
        assert_response 302
      end
    end
  end

  # ToDo:
  #
  # test "a channel's domain status can be polled via ajax" do
  #   perform_enqueued_jobs do
  #     post(publishers_path, params: SIGNUP_PARAMS)
  #   end
  #   publisher = Publisher.order(created_at: :asc).last
  #   url = publisher_url(publisher, token: publisher.authentication_token)
  #   get(url)
  #   follow_redirect!
  #
  #   url = domain_status_publishers_path
  #
  #   # domain has not been set yet
  #   get(url, headers: { 'HTTP_ACCEPT' => "application/json" })
  #   assert_response 404
  #
  #   update_params = {
  #       publisher: {
  #           brave_publisher_id_unnormalized: "pyramid.net",
  #           name: "Alice the Pyramid",
  #           phone: "+14159001420"
  #       }
  #   }
  #
  #   perform_enqueued_jobs do
  #     patch(update_unverified_publishers_path, params: update_params )
  #   end
  #
  #   # domain has been set
  #   get(url, headers: { 'HTTP_ACCEPT' => "application/json" })
  #   assert_response 200
  #   assert_match(
  #       '{"brave_publisher_id":"pyramid.net",' +
  #           '"next_step":"/publishers/verification_choose_method"}',
  #       response.body)
  # end
end
