require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
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

    test "a publisher can add a youtube channel" do
      begin
        publisher = publishers(:uphold_connected)
        request_login_email(publisher: publisher)
        url = publisher_url(publisher, token: publisher.reload.authentication_token)
        get(url)
        follow_redirect!

        OmniAuth.config.test_mode = true

        token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            {
                "provider" => "google_oauth2",
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

        channel_data = {
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
            to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

        assert_difference("Channel.count", 1) do
          get(publisher_google_oauth2_omniauth_authorize_url)
          follow_redirect!
          assert_redirected_to home_publishers_path
        end
        channel = Channel.order(created_at: :asc).last

        assert_equal channel.details.auth_provider, "google_oauth2"
        assert_equal channel.details.auth_user_id, "123545"
        assert_equal channel.details.auth_email, "brand@nonfunctional.google.com"
        assert_not_nil channel.details.youtube_channel_id
        assert_equal "google_oauth2", channel.details.auth_provider
        assert_equal "DIY", channel.details.title
      end
    end

    test "a publisher who adds a channel taken by another will see custom dialog based on the taken channel" do
      begin
        active_promo_id_original = Rails.application.secrets[:active_promo_id]
        Rails.application.secrets[:active_promo_id] = ""
        publisher = publishers(:uphold_connected)
        request_login_email(publisher: publisher)
        url = publisher_url(publisher, token: publisher.reload.authentication_token)
        get(url)
        follow_redirect!

        OmniAuth.config.test_mode = true

        token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            {
                "provider" => "google_oauth2",
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

        channel_data = {
            "id" => "323541525412313421",
            "snippet" => {
                "title" => "The DIY Channel",
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
            to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

        assert_difference("Channel.count", 0) do
          get(publisher_google_oauth2_omniauth_authorize_url)
          follow_redirect!
          assert_redirected_to home_publishers_path
          follow_redirect!
        end

        assert_select('div#channel_taken_modal') do |element|
          assert_match("The DIY Channel", element.text)
        end
        Rails.application.secrets[:active_promo_id] = active_promo_id_original
      end
    end

    test "a publisher who adds a channel taken by themselves will see .channel_already_registered" do
      begin
        active_promo_id_original = Rails.application.secrets[:active_promo_id]
        Rails.application.secrets[:active_promo_id] = ""
        publisher = publishers(:google_verified)
        request_login_email(publisher: publisher)
        url = publisher_url(publisher, token: publisher.reload.authentication_token)
        get(url)
        follow_redirect!

        OmniAuth.config.test_mode = true

        token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            {
                "provider" => "google_oauth2",
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

        channel_data = {
            "id" => "78032",
            "snippet" => {
                "title" => "Some Other Guy's Channel",
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
            to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

        assert_difference("Channel.count", 0) do
          get(publisher_google_oauth2_omniauth_authorize_url)
          follow_redirect!
          assert_redirected_to home_publishers_path
          follow_redirect!
        end

        assert_select('div.notifications') do |element|
          assert_match(I18n.t("publishers.omniauth_callbacks.google_oauth2.channel_already_registered"), element.text)
        end
        Rails.application.secrets[:active_promo_id] = active_promo_id_original
      end
    end
  end
end
