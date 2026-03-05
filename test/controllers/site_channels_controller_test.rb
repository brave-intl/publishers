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
