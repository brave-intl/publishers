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

  test "cancel_add removes an unverified channel and redirects to the dashboard" do
    publisher = publishers(:default)
    channel = channels(:new_site)
    sign_in publisher

    assert_difference("publisher.channels.count", -1) do
      assert_difference("SiteChannelDetails.count", -1) do
        get cancel_add_channel_path(channel)
        assert_redirected_to '/publishers/home'
      end
    end
  end

  test "cancel_add will not remove an already verified channel" do
    publisher = publishers(:verified)
    channel = channels(:verified)
    sign_in publisher

    assert_difference("publisher.channels.count", 0) do
      assert_difference("SiteChannelDetails.count", 0) do
        get cancel_add_channel_path(channel)
        assert_redirected_to '/publishers/home'
      end
    end
  end
end
