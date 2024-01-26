# typed: false

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class AbstractOmniauthCallbacksControllerTest < ActionDispatch::LegacyIntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper
    include MailerTestHelper
    include PublishersHelper
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    test "should not accept YouTube GET requests to OmniAuth endpoint" do
      ActionController::Base.allow_forgery_protection = true
      OmniAuth.config.test_mode = false
      get publisher_register_youtube_channel_omniauth_authorize_url
      assert_response :missing
      ActionController::Base.allow_forgery_protection = false
      OmniAuth.config.test_mode = true
    end

    test "should not accept YoutTube POST requests with invalid CSRF tokens to OmniAuth endpoint" do
      ActionController::Base.allow_forgery_protection = true
      OmniAuth.config.test_mode = false
      post publisher_register_youtube_channel_omniauth_authorize_url
      ActionController::Base.allow_forgery_protection = false
      OmniAuth.config.test_mode = true
      assert_equal flash[:notice], "Invalid attempt, please try again."
      assert_redirected_to root_path(locale: "en")
    end

    test "should not accept Twitter GET requests to OmniAuth endpoint" do
      ActionController::Base.allow_forgery_protection = true
      OmniAuth.config.test_mode = false
      get publisher_register_twitter_channel_omniauth_authorize_url
      assert_response :missing
      ActionController::Base.allow_forgery_protection = false
      OmniAuth.config.test_mode = true
    end

    test "should not accept Twitter POST requests with invalid CSRF tokens to OmniAuth endpoint" do
      ActionController::Base.allow_forgery_protection = true
      OmniAuth.config.test_mode = false
      post publisher_register_twitter_channel_omniauth_authorize_url
      ActionController::Base.allow_forgery_protection = false
      OmniAuth.config.test_mode = true
      assert_equal flash[:notice], "Invalid attempt, please try again."
      assert_redirected_to root_path(locale: "en")
    end

    def request_login_email(publisher:)
      perform_enqueued_jobs do
        get(log_in_publishers_path)
        params = publisher.attributes.slice(*%w[email])
        post(registrations_path, params: params)
      end
    end

    before(:example) do
      OmniAuth.config.test_mode = true
      @active_promo_id_original = Rails.configuration.pub_secrets[:active_promo_id]
      Rails.configuration.pub_secrets[:active_promo_id] = ""
      uphold_url = Rails.configuration.pub_secrets[:uphold_api_uri] + "/v0/me"
      stub_request(:get, uphold_url).to_return(body: {status: "pending", memberAt: "2019", uphold_id: "123e4567-e89b-12d3-a456-426655440000"}.to_json)
      # Mock out the creation of cards
      stub_request(:get, /cards/).to_return(body: [id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"].to_json)
      stub_request(:post, /cards/).to_return(body: {id: "fb25048b-79df-4e64-9c4e-def07c8f5c04"}.to_json)
      stub_request(:get, /address/).to_return(body: [{formats: [{format: "uuid", value: "e306ec64-461b-4723-bf75-015ffc99ebe1"}], type: "anonymous"}].to_json)
    end

    after(:example) do
      Rails.configuration.pub_secrets[:active_promo_id] = @active_promo_id_original
      OmniAuth.config.test_mode = false
    end
  end

  class RegisterYoutubeChannelOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

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

    def channel_data(options = {})
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

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").to_return(status: 200, body: {items: [channel_data]}.to_json, headers: {})

      assert_difference("Channel.count", 1) do
        post(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
      end
      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, "register_youtube_channel"
      assert_equal channel.details.auth_user_id, "123545"
      assert_equal channel.details.auth_email, "brand@nonfunctional.google.com"
      assert_not_nil channel.details.youtube_channel_id
      assert_equal "register_youtube_channel", channel.details.auth_provider
      assert_equal "DIY", channel.details.title
      assert_not_nil channel.details.channel_identifier
      assert_equal channel.derived_brave_publisher_id, channel.details.channel_identifier
    end

    test "a publisher who adds a youtube channel taken by another will see the channel contention message" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").to_return(status: 200, body: {items: [channel_data("id" => "323541525412313421")]}.to_json, headers: {})

      assert_difference("Channel.count", 1) do
        post(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("span.channel-contested") do |element|
        assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)), element.text)
      end
    end

    test "a publisher who adds a youtube channel that has already been contested" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").to_return(status: 200, body: {items: [channel_data("id" => "323541525412313421")]}.to_json, headers: {})

      assert_difference("Channel.count", 1) do
        post(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select(".channel-summary", text: channel_data["snippet"]["title"])

      # Sign the current pub out
      sign_out publisher

      publisher = publishers(:uphold_connected_currency_unconfirmed)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      post(publisher_register_youtube_channel_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to controller: "/publishers", action: "home"
      follow_redirect!

      # Channel was transferred
      assert_select("span.channel-contested") do |element|
        assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)), element.text)
      end

      # Check the previous transfer to make sure it was deleted
      sign_out publisher

      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      assert_select(".channel-secondary-information") do |element|
        refute_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(Channel.where(verification_pending: true).first)), element.text)
      end
    end

    test "a publisher who adds a youtube channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:google_verified)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_youtube_channel] = auth_hash

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").to_return(status: 200, body: {items: [channel_data("id" => "78032")]}.to_json, headers: {})

      assert_difference("Channel.count", 0) do
        post(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("div.notifications") do |element|
        assert_match(I18n.t("publishers.omniauth_callbacks.register_youtube_channel.channel_already_registered"), element.text)
      end
    end
  end

  class YoutubeLoginOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    def token
      "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"
    end

    def auth_hash(options = {})
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

      post(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to controller: "/publishers", action: "change_email"
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

      post(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to controller: "registrations", action: "log_in"
    end

    test "a publisher who was registered by youtube channel signup can't add additional youtube channels" do
      OmniAuth.config.mock_auth[:youtube_login] = auth_hash

      post(publisher_youtube_login_omniauth_authorize_url)
      follow_redirect!
      assert_redirected_to controller: "/publishers", action: "change_email"

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

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics,snippet").to_return(status: 200, body: {items: [register_youtube_channel_data]}.to_json, headers: {})

      assert_difference("Channel.count", 0) do
        post(publisher_register_youtube_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "change_email"
      end
    end
  end

  class TwitchOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    def token
      "ya29.Glz-BARu50BO8bmnXM247jcU42d5GX4LsVm1Vy57rcRxm9TfA_damOV0mX6ZY1H0vL3uxUglXykMC1NmZyr-Lg7J0JYwNkgfkFfKv_jn1ePsikVKkMjz1RqaLT3Hbw"
    end

    def auth_hash(options = {})
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
        post(publisher_register_twitch_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
      end
      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, "twitch"
      assert_equal channel.details.auth_user_id, "123545"
      assert_equal channel.details.email, "brand@nonfunctional.google.com"
      assert_not_nil channel.details.twitch_channel_id
      assert_equal "twitch", channel.details.auth_provider
    end

    test "a publisher who adds a twitch channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:uphold_connected_details)
      verified_details = twitch_channel_details(:uphold_connected_twitch_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitch_channel] = auth_hash("uid" => verified_details[:twitch_channel_id])

      assert_difference("Channel.count", 0) do
        post(publisher_register_twitch_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("div.notifications") do |element|
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

  class TwitterOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    def token
      "459609731-kjE9N6xB6DmRDL8okQykgnEa7MeECh3Fp8enmAkj"
    end

    def auth_hash(options = {})
      OmniAuth::AuthHash.new(
        {"provider" => "register_twitter_channel",
         "uid" => "123545",
         "info" => {
           "name" => "Ted the Twitter User",
           "email" => "ted@example.com",
           "nickname" => "yu_suke1994",
           "description" => "帰って寝たい",
           "image" => "https://pbs.twimg.com/profile_images/974726646438744064/ivNCZILF_normal.jpg",
           "urls" => {
             "Website" => "https://t.co/NCFLB8wDkx",
             "Twitter" => "https://twitter.com/yu_suke1994"
           }
         },
         "credentials" => {
           "token" => token,
           "expires_at" => 1642016242,
           "expires" => true
         },
         "extra" => {
           "raw_info" => {
             "data" => {
               "profile_image_url" => "https://pbs.twimg.com/profile_images/580019517608218624/KzEZSzUy_normal.jpg",
               "url" => "https://t.co/NCFLB8wDkx",
               "public_metrics" => {
                 "followers_count" => 456,
                 "following_count" => 1478,
                 "tweet_count" => 1000,
                 "listed_count" => 110
               },
               "verified" => false,
               "name" => "うなすけ",
               "entities" => {
                 "url" => {
                   "urls" => [{
                     "start" => 0,
                     "end" => 23,
                     "url" => "https://t.co/NCFLB8wDkx",
                     "expanded_url" => "https://unasuke.com", "display_url" => "unasuke.com"
                   }]
                 }
               },
               "description" => "帰って寝たい",
               "created_at" => "2010-01-25T10:10:22.000Z",
               "username" => "tedthetwitteruser",
               "protected" => false,
               "id" => "108252390"
             }
           }
         }}.deep_merge(options)
      )
    end

    test "a publisher can add a twitter channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitter_channel] = auth_hash

      assert_difference("Channel.count", 1) do
        post(publisher_register_twitter_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
      end

      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, "register_twitter_channel"
      assert_equal channel.details.auth_email, "ted@example.com"
      assert_equal channel.details.twitter_channel_id, "123545"
      assert_equal channel.details.auth_provider, "register_twitter_channel"
      assert_equal channel.details.name, "Ted the Twitter User"
      assert_equal channel.details.screen_name, "tedthetwitteruser"
      assert_equal channel.details.thumbnail_url, "https://pbs.twimg.com/profile_images/974726646438744064/ivNCZILF_normal.jpg"
      assert_equal channel.details.stats["followers_count"], 456
      assert_equal channel.details.stats["statuses_count"], 1000
      assert_equal channel.details.stats["verified"], false
    end

    test "a publisher who adds a twitter channel taken by another will see custom dialog based on the taken channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitter_channel] = auth_hash("uid" => "abc124")

      assert_difference("Channel.count", 1) do
        post(publisher_register_twitter_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("span.channel-contested") do |element|
        assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)),
          element.text)
      end
    end

    test "a publisher who adds a twitter channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:uphold_connected_details)
      verified_details = twitter_channel_details(:uphold_connected_twitter_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_twitter_channel] = auth_hash("uid" => verified_details[:twitter_channel_id])

      assert_difference("Channel.count", 0) do
        post(publisher_register_twitter_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("div.notifications") do |element|
        assert_match(I18n.t("publishers.omniauth_callbacks.register_twitter_channel.channel_already_registered"), element.text)
      end
    end
  end

  class VimeoOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    def token
      "459609731-kjE9N6xB6DmRDL8okQykgnEa7MeECh3Fp8enmAkj"
    end

    def auth_hash(options = {})
      OmniAuth::AuthHash.new(
        {
          "uid" => "1000",
          "info" => {
            "name" => "Vince the Vimeo owner",
            "email" => "vince@example.com",
            "id" => "1000",
            "pictures" => [
              {
                link: "https://vimeo.com/small_image.jpg"
              },
              {
                link: "https://vimeo.com/medium_image.jpg"
              },
              {
                link: "https://vimeo.com/big_image.jpg"
              }
            ],
            "link" => "http://vimeo.com/user12345678",
            "nickname" => "Vince Channel",
            "auth_provider" => "register_vimeo_channel"
          },
          "credentials" => {
            "token" => token
          }
        }.deep_merge(options)
      )
    end

    test "a publisher can add a vimeo channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_vimeo_channel] = auth_hash

      assert_difference("Channel.count", 1) do
        post(publisher_register_vimeo_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
      end

      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, auth_hash.info.auth_provider
      assert_equal channel.details.vimeo_channel_id, auth_hash.info.id
      assert_equal channel.details.name, auth_hash.info.name
      assert_equal channel.details.thumbnail_url, auth_hash.info.pictures.last.link
    end

    test "a publisher who adds a vimeo channel taken by another will see custom dialog based on the taken channel" do
      publisher = publishers(:uphold_connected)
      verified_details = vimeo_channel_details(:vimeo_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_vimeo_channel] = auth_hash(
        uid: verified_details.vimeo_channel_id,
        info: {id: verified_details.vimeo_channel_id}
      )

      assert_difference("Channel.count", 1) do
        post(publisher_register_vimeo_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("span.channel-contested") do |element|
        assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)),
          element.text)
      end
    end

    test "a publisher who adds a vimeo channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:channel_publisher)
      verified_details = vimeo_channel_details(:vimeo_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_vimeo_channel] = auth_hash(
        uid: verified_details.vimeo_channel_id,
        info: {id: verified_details.vimeo_channel_id}
      )

      assert_difference("Channel.count", 0) do
        post(publisher_register_vimeo_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("body") do |element|
        assert_select "div.alert", I18n.t("publishers.omniauth_callbacks.register_vimeo_channel.channel_already_registered")
      end
    end
  end

  class RedditOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
    include MockRewardsResponses

    before do
      stub_rewards_parameters
    end

    def token
      "459609731-kjE9N6xB6DmRDL8okQykgnEa7MeECh3Fp8enmAkj"
    end

    def auth_hash(options = {})
      OmniAuth::AuthHash.new(
        {
          "uid" => "12345678",
          "provider" => "register_reddit_channel",
          "info" => {
            "name" => "Reggie the Redditor"
          },
          "extra" => {
            "raw_info" => {
              "icon_img" => "abc.com"
            }
          }
        }.deep_merge(options)
      )
    end

    test "a publisher can add a reddit channel" do
      publisher = publishers(:uphold_connected)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_reddit_channel] = auth_hash

      assert_difference("Channel.count", 1) do
        post(publisher_register_reddit_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
      end

      channel = Channel.order(created_at: :asc).last

      assert_equal channel.details.auth_provider, auth_hash.provider
      assert_equal channel.details.reddit_channel_id, auth_hash.uid
      assert_equal channel.details.name, auth_hash.info.name
      assert_equal channel.details.thumbnail_url, auth_hash.extra.raw_info.icon_img
    end

    test "a publisher who adds a reddit channel taken by another will see custom dialog based on the taken channel" do
      publisher = publishers(:uphold_connected)
      verified_details = reddit_channel_details(:reddit_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_reddit_channel] = auth_hash(
        uid: verified_details.reddit_channel_id,
        info: {id: verified_details.reddit_channel_id}
      )

      assert_difference("Channel.count", 1) do
        post(publisher_register_reddit_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("span.channel-contested") do |element|
        assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)),
          element.text)
      end
    end

    test "a publisher who adds a reddit channel taken by themselves will see .channel_already_registered" do
      publisher = publishers(:channel_publisher)
      verified_details = reddit_channel_details(:reddit_details)
      request_login_email(publisher: publisher)
      url = publisher_url(publisher, token: publisher.reload.authentication_token)
      get(url)
      follow_redirect!

      OmniAuth.config.mock_auth[:register_reddit_channel] = auth_hash(
        uid: verified_details.reddit_channel_id,
        info: {id: verified_details.reddit_channel_id}
      )

      assert_difference("Channel.count", 0) do
        post(publisher_register_reddit_channel_omniauth_authorize_url)
        follow_redirect!
        assert_redirected_to controller: "/publishers", action: "home"
        follow_redirect!
      end

      assert_select("body") do |element|
        assert_select "div.alert", I18n.t("publishers.omniauth_callbacks.register_reddit_channel.channel_already_registered")
      end
    end
  end

  # class GithubOmniauthCallbacksControllerTest < AbstractOmniauthCallbacksControllerTest
  #   def token
  #     "459609731-kjE9N6xB6DmRDL8okQykgnEa7MeECh3Fp8enmAkj"
  #   end
  #
  #   def auth_hash(options = {})
  #     OmniAuth::AuthHash.new(
  #       {
  #         "uid" => "12345678",
  #         "provider" => "register_github_channel",
  #         "info" => {
  #           "name" => "GitHub New",
  #           "image" => "https://some_image_host.com/some_image.png",
  #           "urls" => {
  #             GitHub: "https://github.com/user/user12345678"
  #           }
  #         }
  #       }.deep_merge(options)
  #     )
  #   end
  #
  #   test "a publisher can add a github channel" do
  #     publisher = publishers(:uphold_connected)
  #     request_login_email(publisher: publisher)
  #     url = publisher_url(publisher, token: publisher.reload.authentication_token)
  #     get(url)
  #     follow_redirect!
  #
  #     OmniAuth.config.mock_auth[:register_github_channel] = auth_hash
  #
  #     assert_difference("Channel.count", 1) do
  #       post(publisher_register_github_channel_omniauth_authorize_url)
  #       follow_redirect!
  #       assert_redirected_to controller: "/publishers", action: "home"
  #     end
  #
  #     channel = Channel.order(created_at: :asc).last
  #
  #     assert_equal channel.details.auth_provider, auth_hash.provider
  #     assert_equal channel.details.github_channel_id, auth_hash.uid
  #     assert_equal channel.details.name, auth_hash.info.name
  #     assert_equal channel.details.thumbnail_url, auth_hash.info.image
  #   end
  #
  #   test "a publisher who adds a github channel taken by another will see custom dialog based on the taken channel" do
  #     publisher = publishers(:uphold_connected)
  #     verified_details = github_channel_details(:github_details)
  #     request_login_email(publisher: publisher)
  #     url = publisher_url(publisher, token: publisher.reload.authentication_token)
  #     get(url)
  #     follow_redirect!
  #
  #     OmniAuth.config.mock_auth[:register_github_channel] = auth_hash(
  #       uid: verified_details.github_channel_id,
  #       info: {id: verified_details.github_channel_id}
  #     )
  #
  #     assert_difference("Channel.count", 1) do
  #       post(publisher_register_github_channel_omniauth_authorize_url)
  #       follow_redirect!
  #       assert_redirected_to controller: "/publishers", action: "home"
  #       follow_redirect!
  #     end
  #
  #     assert_select("span.channel-contested") do |element|
  #       assert_match(I18n.t("shared.channel_contested", time_until_transfer: time_until_transfer(publisher.channels.where(verification_pending: true).first)),
  #         element.text)
  #     end
  #   end
  #
  #   test "a publisher who adds a github channel taken by themselves will see .channel_already_registered" do
  #     publisher = publishers(:channel_publisher)
  #     verified_details = github_channel_details(:github_details)
  #     request_login_email(publisher: publisher)
  #     url = publisher_url(publisher, token: publisher.reload.authentication_token)
  #     get(url)
  #     follow_redirect!
  #
  #     OmniAuth.config.mock_auth[:register_github_channel] = auth_hash(
  #       uid: verified_details.github_channel_id,
  #       info: {id: verified_details.github_channel_id}
  #     )
  #
  #     assert_difference("Channel.count", 0) do
  #       post(publisher_register_github_channel_omniauth_authorize_url)
  #       follow_redirect!
  #       assert_redirected_to controller: "/publishers", action: "home"
  #       follow_redirect!
  #     end
  #
  #     assert_select("body") do |element|
  #       assert_select "div.alert", I18n.t("publishers.omniauth_callbacks.register_github_channel.channel_already_registered")
  #     end
  #   end
  # end
end
