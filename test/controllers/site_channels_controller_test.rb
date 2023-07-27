# typed: false

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class SiteChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PublishersHelper

  before do
    @prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
  end

  after do
    Rails.configuration.pub_secrets[:host_inspector_offline] = @prev_host_inspector_offline
  end

  test "should allow configurable limmit for creating channel for logged in publisher" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]

    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true
      publisher = publishers(:verified)
      publisher.update!(site_channel_limit: 3)
      second_channel = channels(:default)
      second_channel.update!(publisher_id: publisher.id)

      sign_in publishers(:verified)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "new_site_54634.org"
          }
        }
      }

      assert_equal(2, publisher.channels.count)

      assert_difference("publisher.channels.count") do
        post site_channels_url, params: create_params
      end

      new_channel = publisher.channels.order(created_at: :asc).last

      assert_redirected_to controller: "/site_channels", action: "verification_choose_method", id: new_channel.id
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "should limit number of site channels logged in publisher" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]

    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true
      publisher = publishers(:verified)
      second_channel = channels(:default)
      second_channel.update!(publisher_id: publisher.id)

      sign_in publishers(:verified)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "new_site_54634.org"
          }
        }
      }

      assert_equal(2, publisher.channels.count)
      post site_channels_url, params: create_params
      publisher.reload
      assert_equal(2, publisher.channels.count)
      assert_equal(302, response.status)
      assert_equal(I18n.t("site_channels.shared.limit"), flash.alert)
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "should create channel for logged in publisher" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]

    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true
      publisher = publishers(:verified)

      sign_in publishers(:verified)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "new_site_54634.org"
          }
        }
      }

      assert_equal(1, publisher.channels.count)

      assert_difference("publisher.channels.count") do
        post site_channels_url, params: create_params
      end

      new_channel = publisher.channels.order(created_at: :asc).last

      assert_redirected_to controller: "/site_channels", action: "verification_choose_method", id: new_channel.id
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "verify can verify the channel and redirect to the dashboard" do
    Rails.configuration.pub_secrets[:host_inspector_offline] = false
    channel = channels(:global_inprocess)

    sign_in publishers(:global_media_group)

    url = %r{\Ahttps://.*/\.well-known/brave-rewards-verification\.txt\z}
    headers = {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Ruby",
      "Host" => channel.details.brave_publisher_id
    }
    body = SiteChannelVerificationFileGenerator.new(site_channel: channel).generate_file_content
    stub_request(:get, url)
      .with(headers: headers)
      .to_return(status: 200, body: body, headers: {})

    patch(verify_site_channel_path(channel.id, verification_method: channel.details.verification_method))
    channel.reload
    assert channel.verified?
    assert_redirected_to controller: "/publishers", action: "home"
  end

  test "can't create verified Site Channel with an existing verified Site Channel with the same brave_publisher_id" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true

      sign_in publishers(:verified)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "verified.org"
          }
        }
      }

      assert_difference("Channel.count", 0) do
        post site_channels_url, params: create_params
      end

      assert_select("[data-test-flash-message]") do |element|
        assert_match(I18n.t("site_channels.create.duplicate_channel", domain: "verified.org"), element.text)
      end
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  #  test "can't create a Site Channel with an existing visible Site Channel with the same brave_publisher_id" do
  #    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
  #
  #    begin
  #      Rails.configuration.pub_secrets[:host_inspector_offline] = true
  #
  #      before do
  #        Channel.delete_all
  #      end
  #
  #      existing = site_channel_details(:new_site_details2)
  #
  #      sign_in publishers(:verified)
  #
  #      create_params = {
  #        channel: {
  #          details_attributes: {
  #            brave_publisher_id_unnormalized: "new_site.org"
  #          }
  #        }
  #      }
  #
  #      perform_enqueued_jobs
  #
  #      assert_difference("Channel.count", 1) do
  #        post site_channels_url, params: create_params
  #      end
  #
  #      # Make sure channel will be visible in the channel list
  #      last_channel = Channel.order(created_at: :asc).last
  #      last_channel.details.verification_method = "wordpress"
  #      last_channel.save!
  #
  #      refute_difference("Channel.count") do
  #        post site_channels_url, params: create_params
  #      end
  #
  #      assert_select("[data-test-flash-message]") do |element|
  #        assert_match("newsite.org is already present.", element.text)
  #      end
  #    ensure
  #      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
  #    end
  #  end
  #
  test "a publisher who was registered by youtube channel signup can't add additional site channels" do
    OmniAuth.config.test_mode = true

    token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

    OmniAuth.config.mock_auth[:youtube_login] = OmniAuth::AuthHash.new(
      {
        "provider" => "youtube_login",
        "uid" => "joe123456",
        "info" => {
          "name" => "Joe's awesome stuff",
          "email" => "joes-great-channel@pages.plusgoogle.com",
          "first_name" => "Joe",
          "image" => "https://some_image_host.com/some_image.png"
        },
        "credentials" => {
          "token" => token,
          "expires_at" => 2510156374,
          "expires" => true
        }
      }
    )

    post(publisher_youtube_login_omniauth_authorize_url)
    follow_redirect!
    assert_redirected_to controller: "/publishers", action: "change_email"

    create_params = {
      channel: {
        details_attributes: {
          brave_publisher_id_unnormalized: "new_site_54634.org"
        }
      }
    }

    assert_difference("Channel.count", 0) do
      post site_channels_url, params: create_params
      assert_redirected_to controller: "/publishers", action: "home"
      follow_redirect!
      assert_redirected_to controller: "/publishers", action: "change_email"
    end
  end

  test "when channel creation exceeds the limit" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true

      sign_in publishers(:promo_enabled)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "new_site_54634.org"
          }
        }
      }

      count = Channel.count
      post site_channels_url, params: create_params
      assert Channel.count == count
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "when user only is in status 'only user funds' we do not register for promos" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true
      publisher = publishers(:promo_enabled_but_only_user_funds)

      sign_in publishers(:promo_enabled_but_only_user_funds)

      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "new_site_54634.org"
          }
        }
      }

      assert_difference("publisher.channels.count") do
        post site_channels_url, params: create_params
      end

      new_channel = publisher.channels.order(created_at: :asc).last

      assert_enqueued_jobs(0) do
        new_channel.update(verified: true)
      end
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end
  test "two different publishers can have the same unverifed site channel" do
    prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
    begin
      Rails.configuration.pub_secrets[:host_inspector_offline] = true
      create_params = {
        channel: {
          details_attributes: {
            brave_publisher_id_unnormalized: "newsite.org"
          }
        }
      }

      # create the first unverified site channel
      publisher = publishers(:verified)

      sign_in publisher
      assert_difference("Channel.count", 1) do
        post site_channels_url, params: create_params
      end

      sign_out publisher

      # create the second instance of the unverified site channel
      publisher = publishers(:completed)
      sign_in publisher

      assert_difference("Channel.count", 1) do
        post site_channels_url, params: create_params
      end

      assert SiteChannelDetails.where(brave_publisher_id: "newsite.org").count, 2
    ensure
      Rails.configuration.pub_secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end
end
