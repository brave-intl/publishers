require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class AbstractOmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper
    include MailerTestHelper
    include PublishersHelper

    def request_login_email(publisher:)
      perform_enqueued_jobs do
        get(new_auth_token_publishers_path)
        params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id email)) }
        post(create_auth_token_publishers_path, params: params)
      end
    end

    before(:example) do
      OmniAuth.config.test_mode = true
      @active_promo_id_original = Rails.application.secrets[:active_promo_id]
      Rails.application.secrets[:active_promo_id] = ""
    end

    after(:example) do
      Rails.application.secrets[:active_promo_id] = @active_promo_id_original
      OmniAuth.config.test_mode = false
    end
  end

  class RegisterYoutubeChannelOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest

    def token
      "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"
    end

    def auth_hash
      OmniAuth::AuthHash.new(
          {
              "provider" => "register_youtube_channel",
              "uid" => "123545",
              "info" => {
                  "name" => "Test Brand Account",
                  "email" => "brand@nonfunctional.google.com",
                  "first_name" => "Test Brand Account",
                  "image" => "https://lh4.googleusercontent.com/-tP57axXeGuI/AAAAAAAAAAI/AAAAAAAAAA0/LSxNfj3nB8c/photo.jpg"
              },
              "credentials" => {
                  "token" => token,
                  "expires_at" => 2510156374,
                  "expires" => true
              }
          }
      )
    end

    def channel_data(options={})
      {
          "id" => "234542342332134",
          "snippet" => {
              "title" => "DIY",
              "description" => "DIY Description",
              "thumbnails" => {
                  "default" => {
                      "url" => "http://some_host.com/thumb.png"
                  }
              }
          },
          "statistics" => {
              "subscriberCount" => 12
          }
      }.deep_merge(options)
    end

    test "a publisher can add a youtube channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Authorization' => "Bearer #{token}",
                          'User-Agent' => 'Faraday v0.9.2' }).
          to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

      assert_difference("Channel.count", 1) do
        get(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
      end
      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, "register_youtube_channel"
      assert_equal channel.details.auth_user_id, "123545"
      assert_equal channel.details.auth_email, "brand@nonfunctional.google.com"
      assert_not_nil channel.details.youtube_channel_id
      assert_equal "register_youtube_channel", channel.details.auth_provider
      assert_equal "DIY", channel.details.title
    end

    test "a publisher who adds a channel taken by another will see custom dialog based on the taken channel" do

      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Authorization' => "Bearer #{token}",
                          'User-Agent' => 'Faraday v0.9.2' }).
          to_return(status: 200, body: { items: [channel_data("id" => "323541525412313421")] }.to_json, headers: {})

      assert_difference("Channel.count", 0) do
        get(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
        follow_redirect!
      end

      assert_select('div#channel_taken_modal') do |element|
        assert_match("The DIY Channel", element.text)
      end
    end

    test "a publisher who adds a channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:google_verified)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Authorization' => "Bearer #{token}",
                          'User-Agent' => 'Faraday v0.9.2' }).
          to_return(status: 200, body: { items: [channel_data("id" => "78032")] }.to_json, headers: {})

      assert_difference("Channel.count", 0) do
        get(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
        follow_redirect!
      end

      assert_select('div.notifications') do |element|
        assert_match(I18n.t("publishers.omniauth_callbacks.register_youtube_channel.channel_already_registered"), element.text)
      end
    end
  end

  class YoutubeLoginOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest

    def token
      "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"
    end

    def auth_hash options={}
      OmniAuth::AuthHash.new(
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
          }.deep_merge(options)
      )
    end

    test "a publisher who only has a google plus email can login using their login channel" do
      OmniAuth.config.mock_auth[:youtube_login] = auth_hash

      get(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to change_email_publishers_path
    end

    test "a publisher who does not have a google plus email can not login using their login channel" do
      OmniAuth.config.mock_auth[:youtube_login] = auth_hash(
          "uid" => "global_yt1_details_abc123",
          "info" => {
              "name" => "Global 1",
              "email" => "global_yt1_details@pages.plusgoogle.com",
              "first_name" => "Global 1"
          }
      )

      get(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to new_auth_token_publishers_path
    end

    test "a publisher who was registered by youtube channel signup can't add additional youtube channels" do
      OmniAuth.config.mock_auth[:youtube_login] = auth_hash

      get(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to change_email_publishers_path

      OmniAuth.config.mock_auth[:register_youtube_channel] = OmniAuth::AuthHash.new(
          {
              "provider" => "register_youtube_channel",
              "uid" => "123545",
              "info" => {
                  "name" => "Test Brand Account",
                  "email" => "brand@nonfunctional.google.com",
                  "first_name" => "Test Brand Account",
                  "image" => "https://lh4.googleusercontent.com/-tP57axXeGuI/AAAAAAAAAAI/AAAAAAAAAA0/LSxNfj3nB8c/photo.jpg"
              },
              "credentials" => {
                  "token" => token,
                  "expires_at" => 2510156374,
                  "expires" => true
              }
          }
      )

      register_youtube_channel_data = {
          "id" => "234542342332134",
          "snippet" => {
              "title" => "DIY",
              "description" => "DIY Description",
              "thumbnails" => {
                  "default" => {
                      "url" => "http://some_host.com/thumb.png"
                  }
              }
          },
          "statistics" => {
              "subscriberCount" => 12
          }
      }

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").
          with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                          'Authorization' => "Bearer #{token}",
                          'User-Agent' => 'Faraday v0.9.2' }).
          to_return(status: 200, body: { items: [register_youtube_channel_data] }.to_json, headers: {})

      assert_difference("Channel.count", 0) do
        get(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
        follow_redirect!
        assert_redirected_to change_email_publishers_path
      end
    end
  end

  class TwitchOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest

    def token
      "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"
    end

    def auth_hash(options={})
      OmniAuth::AuthHash.new(
          {
              "provider" => "twitch",
              "uid" => "123545",
              "info" => {
                  "name" => "TwTwTw",
                  "nickname" => "twtwtw",
                  "email" => "brand@nonfunctional.google.com",
                  "image" => "https://some_host/-tP57axXeGuI/AAAAAAAAAAI/AAAAAAAAAA0/LSxNfj3nB8c/photo.jpg"
              },
              "credentials" => {
                  "token" => token,
                  "expires_at" => 2510156374,
                  "expires" => true
              }
          }.deep_merge(options)
      )
    end

    test "a publisher can add a twitch channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitch_channel] = auth_hash

      assert_difference("Channel.count", 1) do
        get(publisher_register_twitch_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
      end
      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, "twitch"
      assert_equal channel.details.auth_user_id, "123545"
      assert_equal channel.details.email, "brand@nonfunctional.google.com"
      assert_not_nil channel.details.twitch_channel_id
      assert_equal "twitch", channel.details.auth_provider
    end

    test "a publisher who adds a channel taken by another will see custom dialog based on the taken channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitch_channel] = auth_hash("uid" => "323541525412313421")

      assert_difference("Channel.count", 0) do
        get(publisher_register_twitch_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
        follow_redirect!
      end

      assert_select('div#channel_taken_modal') do |element|
        assert_match("TwTwTw", element.text)
      end
    end

    test "a publisher who adds a channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:twitch_verified)
      verified_details = twitch_channel_details(:twitch_verified_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitch_channel] = auth_hash("uid" => verified_details[:twitch_channel_id])

      assert_difference("Channel.count", 0) do
        get(publisher_register_twitch_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to home_publishers_path
        follow_redirect!
      end

      assert_select('div.notifications') do |element|
        assert_match(
          I18n.t(
            "publishers.omniauth_callbacks.register_twitch_channel.channel_already_registered",
            channel_title: verified_details.display_name
          ),
          element.text
        )
      end
    end

  end
end
