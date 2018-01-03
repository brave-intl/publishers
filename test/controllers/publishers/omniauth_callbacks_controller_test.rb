require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper
    include MailerTestHelper
    include PublishersHelper

    SIGNUP_PARAMS = {
        email: "alice@example.com"
    }.freeze

    test "credentials are associated with the current publisher if it exists" do
      begin
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

        perform_enqueued_jobs do
          post(publishers_path, params: SIGNUP_PARAMS)
        end
        publisher = Publisher.order(created_at: :asc).last
        url = publisher_url(publisher, token: publisher.authentication_token)
        get(url)

        publisher.verified = true
        publisher.save!

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

        get(publisher_google_oauth2_omniauth_authorize_url)
        follow_redirect!

        publisher.reload

        assert_not_nil publisher.youtube_channel_id
        assert_equal "google_oauth2", publisher.auth_provider
        assert_equal "Test Brand Account", publisher.name
      end
    end

    test "a new publisher is sent back to email_verified if a channel exists" do
      begin
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

        perform_enqueued_jobs do
          post(publishers_path, params: SIGNUP_PARAMS)
        end
        publisher = Publisher.order(created_at: :asc).last
        url = publisher_url(publisher, token: publisher.authentication_token)
        get(url)

        publisher.verified = true
        publisher.save!

        diy_channel = youtube_channels(:diy_channel)

        channel_data = {
            "id" => diy_channel.id,
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

        get(publisher_google_oauth2_omniauth_authorize_url)
        follow_redirect!

        publisher.reload

        # All OAuth set fields should be nil
        assert_nil publisher.youtube_channel_id
        assert_nil publisher.auth_provider
        assert_nil publisher.auth_name
        assert_nil publisher.auth_user_id
        assert_nil publisher.name
        assert_nil publisher.auth_email
        refute publisher.verified

        # should redirect to email_verified so user can try another youtube account
        assert_redirected_to email_verified_publishers_path
        follow_redirect!

        assert_select('div#taken_youtube_channel_modal h1') do |element|
          assert_match(I18n.translate('publishers.youtube_channel_taken_dialog.title'), element.text)
        end
      end
    end

    test "an email verified publisher logging into the same oauth account and having the same email as an existing publisher is logged in as that publisher" do
      begin
        OmniAuth.config.test_mode = true

        token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            {
                "provider" => "google_oauth2",
                "uid" => "abc123",
                "info" => {
                    "name" => "Some Other Guy's Channel",
                    "email" => "brand@nonfunctional.google.com",
                    "first_name" => "Test Brand Account",
                    "image" => "https://some_image_host.com/some_image.png"
                },
                "credentials" => {
                    "token" => token,
                    "expires_at" => 2510156374,
                    "expires" => true
                }
            }
        )

        # signup using an email that is already used for an existing youtube publisher
        assert_difference("Publisher.count", 1) do
          perform_enqueued_jobs do
            post(publishers_path, params: { email: "alice@verified.org" })
          end
        end

        publisher = Publisher.order(created_at: :asc).last
        url = publisher_url(publisher, token: publisher.authentication_token)
        get(url)

        some_other_channel = youtube_channels(:some_other_channel)

        channel_data = {
            "id" => some_other_channel.id,
            "snippet" => {
                "title" => "Some Other Guy's Channel",
                "description" => "Some Other Guy's Channel",
                "thumbnails" => {
                    "default" => {
                        "url" => "http://some_host.com/thumb.png"
                    }
                }
            },
            "statistics" => {
                "subscriberCount" => 1200
            }
        }

        stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{some_other_channel.id}&part=statistics,snippet").
            with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Authorization' => "Bearer #{token}",
                            'User-Agent' => 'Faraday v0.9.2' }).
            to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

        assert_difference("Publisher.count", -1) do
          get(publisher_google_oauth2_omniauth_authorize_url)
          follow_redirect!
        end

        assert_raises ActiveRecord::RecordNotFound do
          publisher.reload
        end

        # should redirect to the existing publishers home page, as the existing publisher
        assert_redirected_to home_publishers_path
        follow_redirect!
        assert_select('.publisher-youtube-channel .channel-name') do |element|
          assert_match("Some Other Guy's Channel", element.text)
        end
      end
    end

    test "a new publisher who hasn't verified through email will be created and sent to the dashboard" do
      begin
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

        assert_difference("Publisher.count", 1) do
          get(publisher_google_oauth2_omniauth_authorize_url)
          follow_redirect!
          assert_redirected_to home_publishers_path
        end
        publisher = Publisher.order(created_at: :asc).last

        assert_equal publisher.auth_provider, "google_oauth2"
        assert_equal publisher.auth_user_id, "123545"
        assert_equal publisher.email, "brand@nonfunctional.google.com"
        assert_not_nil publisher.youtube_channel_id
        assert_equal "google_oauth2", publisher.auth_provider
        assert_equal "Test Brand Account", publisher.name
      end
    end

    test "an existing publisher will be logged in and sent to the dashboard" do
      begin
        OmniAuth.config.test_mode = true

        token = "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"

        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            {
                "provider" => "google_oauth2",
                "uid" => "abc123",
                "info" => {
                    "name" => "The DIY Channel",
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

        some_other_channel = youtube_channels(:some_other_channel)

        channel_data = {
            "id" => some_other_channel.id,
            "snippet" => {
                "title" => "Some Other Guy's Channel",
                "description" => "Some Other Guy's Channel",
                "thumbnails" => {
                    "default" => {
                        "url" => "http://some_host.com/thumb.png"
                    }
                }
            },
            "statistics" => {
                "subscriberCount" => 1200
            }
        }

        stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?id=#{some_other_channel.id}&part=statistics,snippet").
            with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Authorization' => "Bearer #{token}",
                            'User-Agent' => 'Faraday v0.9.2' }).
            to_return(status: 200, body: { items: [channel_data] }.to_json, headers: {})

        get(publisher_google_oauth2_omniauth_authorize_url)
        follow_redirect!

        # should redirect to email_verified so user can try another youtube account
        assert_redirected_to home_publishers_path
      end
    end

    test "an authenticated publisher will be redirected to the email verified page on an oauth failure" do
      OmniAuth.config.test_mode = true

      perform_enqueued_jobs do
        post(publishers_path, params: SIGNUP_PARAMS)
      end
      publisher = Publisher.order(created_at: :asc).last
      url = publisher_url(publisher, token: publisher.authentication_token)
      get(url)

      publisher.verified = true
      publisher.save!

      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      get(publisher_google_oauth2_omniauth_authorize_url)
      follow_redirect!

      assert_redirected_to email_verified_publishers_path
    end

    test "an unauthenticated publisher will be redirected to the landing page on an oauth failure" do
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      get(publisher_google_oauth2_omniauth_authorize_url)
      follow_redirect!

      assert_redirected_to '/'
    end
  end
end
