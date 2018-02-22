require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class SiteChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PublishersHelper

  test "should create channel for logged in publisher" do
    prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
    begin
      Rails.application.secrets[:host_inspector_offline] = true
      publisher = publishers(:verified)

      sign_in publishers(:verified)

      create_params = {
          channel: {
              details_attributes: {
                  brave_publisher_id_unnormalized: "new_site_54634.org"
              }
          }
      }

      assert_difference('publisher.channels.count') do
        post site_channels_url, params: create_params
      end

      new_channel = publisher.channels.order(created_at: :asc).last

      assert_redirected_to verification_choose_method_site_channel_path(new_channel)
    ensure
      Rails.application.secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "should create a VerifySiteChannel job to verify and render verification_background page" do
    prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
    begin
      Rails.application.secrets[:host_inspector_offline] = true

      publisher = publishers(:global_media_group)
      channel = channels(:global_inprocess)

      sign_in publishers(:global_media_group)

      assert_enqueued_with(job: VerifySiteChannel) do
        patch(verify_site_channel_path(channel.id))
      end

      assert_template :verification_background
    ensure
      Rails.application.secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "can't create verified Site Channel with an existing verified Site Channel with the same brave_publisher_id" do
    prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
    begin
      Rails.application.secrets[:host_inspector_offline] = true

      publisher = publishers(:verified)

      sign_in publishers(:verified)

      create_params = {
          channel: {
              details_attributes: {
                brave_publisher_id_unnormalized: "verified.org"
              }
          }
      }

      perform_enqueued_jobs do

      end
      assert_difference("Channel.count", 0) do
        post site_channels_url, params: create_params
      end

      assert_select('div#flash') do |element|
        assert_match("The domain you entered is already verified and added to a different account", element.text)
      end
    ensure
      Rails.application.secrets[:host_inspector_offline] = prev_host_inspector_offline
    end
  end

  test "a publisher who was registered by youtube channel signup can't add additional site channels" do
    begin
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

      get(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to change_email_publishers_path

      create_params = {
          channel: {
              details_attributes: {
                  brave_publisher_id_unnormalized: "new_site_54634.org"
              }
          }
      }

      assert_difference("Channel.count", 0) do
        post site_channels_url, params: create_params
        assert_redirected_to home_publishers_path
        follow_redirect!
        assert_redirected_to change_email_publishers_path
      end
    end
  end

  # ToDo:
  # test "a site channel's domain can be updated via an ajax patch" do
  #   publisher = publishers(:verified)
  #
  #   sign_in publishers(:verified)
  #
  #   perform_enqueued_jobs do
  #     patch(update_unverified_publishers_path, params: PUBLISHER_PARAMS)
  #   end
  #
  #   update_params = {
  #       publisher: {
  #           brave_publisher_id_unnormalized: "verified.org",
  #           name: "Alice the Pyramid",
  #           phone: "+14159001420"
  #       }
  #   }
  #
  #   url = update_unverified_publishers_path
  #
  #   perform_enqueued_jobs do
  #     patch(url,
  #           params: update_params,
  #           headers: { 'HTTP_ACCEPT' => "application/json" })
  #     assert_response 204
  #   end
  #
  #   publisher.reload
  #   assert_equal 'taken', publisher.brave_publisher_id_error_code
  #   assert_nil publisher.brave_publisher_id
  #   assert_nil publisher.brave_publisher_id_unnormalized
  #
  #   # Now retry with a unique domain
  #
  #   update_params = {
  #       publisher: {
  #           brave_publisher_id_unnormalized: "this-one-is-unique.org",
  #           name: "Alice the Pyramid",
  #           phone: "+14159001420"
  #       }
  #   }
  #
  #   url = update_unverified_publishers_path
  #
  #   perform_enqueued_jobs do
  #     patch(url,
  #           params: update_params,
  #           headers: { 'HTTP_ACCEPT' => "application/json" })
  #     assert_response 204
  #   end
  #
  #   publisher.reload
  #   assert_nil publisher.brave_publisher_id_error_code
  #   assert_equal 'this-one-is-unique.org', publisher.brave_publisher_id
  #   assert_nil publisher.brave_publisher_id_unnormalized
  # end

  # test "a site channel's domain can be rechecked for https support after an initial failure" do
  #   prev_host_inspector_offline = Rails.application.secrets[:host_inspector_offline]
  #   begin
  #     Rails.application.secrets[:host_inspector_offline] = false
  #
  #     perform_enqueued_jobs do
  #       post(publishers_path, params: SIGNUP_PARAMS)
  #     end
  #     publisher = Publisher.order(created_at: :asc).last
  #     url = publisher_url(publisher, token: publisher.authentication_token)
  #     get(url)
  #     follow_redirect!
  #     perform_enqueued_jobs do
  #       patch(update_unverified_publishers_path, params: PUBLISHER_PARAMS)
  #     end
  #
  #     publisher.verification_method = "public_file"
  #     publisher.save
  #
  #     update_params = {
  #         publisher: {
  #             brave_publisher_id_unnormalized: "this-one-is-unique.org",
  #             name: "Alice the Pyramid",
  #             phone: "+14159001420"
  #         }
  #     }
  #
  #     stub_request(:get, "http://this-one-is-unique.org").
  #         to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})
  #     stub_request(:get, "https://this-one-is-unique.org").
  #         to_raise(Errno::ECONNREFUSED.new)
  #     stub_request(:get, "https://www.this-one-is-unique.org").
  #         to_raise(Errno::ECONNREFUSED.new)
  #
  #     perform_enqueued_jobs do
  #       patch(update_unverified_publishers_path,
  #             params: update_params,
  #             headers: { 'HTTP_ACCEPT' => "application/json" })
  #       assert_response 204
  #     end
  #
  #     publisher.reload
  #     assert_nil publisher.brave_publisher_id_error_code
  #     assert_equal 'this-one-is-unique.org', publisher.brave_publisher_id
  #     assert_nil publisher.brave_publisher_id_unnormalized
  #     refute publisher.supports_https
  #
  #     stub_request(:get, "https://this-one-is-unique.org").
  #         to_return(status: 200, body: "<html><body><h1>Welcome to mysite</h1></body></html>", headers: {})
  #
  #     perform_enqueued_jobs do
  #       patch(check_for_https_publishers_path)
  #       assert_response 302
  #       assert_redirected_to '/publishers/verification_public_file'
  #     end
  #
  #     publisher.reload
  #     assert publisher.supports_https
  #
  #   ensure
  #     Rails.application.secrets[:host_inspector_offline] = prev_host_inspector_offline
  #   end
  # end

  #
  # test "a site channel's domain status can be polled via ajax" do
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
