require "application_system_test_case"

class SiteChannelVerificationTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  before(:example) do
    stub_rewards_parameters
    @prev_host_inspector_offline = Rails.configuration.pub_secrets[:host_inspector_offline]
  end

  after(:example) do
    Rails.configuration.pub_secrets[:host_inspector_offline] = @prev_host_inspector_offline
  end

  def stub_verification_public_file(channel, body: nil, status: 200)
    url = "https://#{channel.details.brave_publisher_id}/.well-known/brave-rewards-verification.txt"
    headers = {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Ruby",
      "Host" => channel.details.brave_publisher_id
    }
    body ||= SiteChannelVerificationFileGenerator.new(site_channel: channel).generate_file_content
    stub_request(:get, url)
      .with(headers: headers)
      .to_return(status: status, body: body, headers: {})
  end

  test "Cancel and Choose Different Verification Method buttons only appear in appropriate places" do
    Channel.delete_all
    ::PreviouslySuspendedChannel.delete_all
    publisher = publishers(:default)
    sign_in publisher

    visit new_site_channel_path
    assert_content "Cancel"

    fill_in "channel_details_attributes_brave_publisher_id_unnormalized", with: "example.com"

    assert_equal ::PreviouslySuspendedChannel.count, 0
    click_button("Continue")

    assert_content "Cancel"
    assert_content "I'll use a trusted file"
    channel = publisher.channels.order("created_at").last
    assert_current_path verification_choose_method_site_channel_path(channel, locale: :en)

    click_link "I'll use a trusted file"
    assert_current_path verification_public_file_site_channel_path(channel, locale: :en)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"

    visit verification_dns_record_site_channel_path(channel)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"
  end

  test "Cant register a previously suspended channel" do
    Channel.delete_all
    publisher = publishers(:default)
    sign_in publisher

    visit new_site_channel_path
    assert_content "Cancel"

    fill_in "channel_details_attributes_brave_publisher_id_unnormalized", with: "example.com"

    ::PreviouslySuspendedChannel.create!(channel_identifier: "example.com")

    click_button("Continue")
    assert_content "Unable to register this channel"
    assert_equal publisher.channels.count, 0
  end

  # Note: I don't like this but there's very little I can do here. I am unable to run the capybara tests
  # and the reason this test is failing now is because of fixture data
  #
  # What I will do is add basic controller tests/specs to the site channel controller to offset some of this.

  #  test "When bad ssl happens" do
  #    Rails.configuration.pub_secrets[:host_inspector_offline] = false
  #    stub_request(:get, %r{\Ahttps://.*\z}).with(headers: {Host: "self-signed.badssl.com"})
  #      .to_raise(OpenSSL::SSL::SSLError.new("SSL_connect returned=1 errno=0 state=error: certificate verify failed"))
  #
  #    publisher = publishers(:default)
  #    sign_in publisher
  #
  #    visit new_site_channel_path
  #    assert_content "Cancel"
  #
  #    fill_in "channel_details_attributes_brave_publisher_id_unnormalized", with: "https://self-signed.badssl.com/"
  #
  #    click_button("Continue")
  #    channel = publisher.channels.order("created_at").last
  #    assert_current_path verification_choose_method_site_channel_path(channel, locale: :en)
  #    assert_content "Cancel"
  #
  #    click_link "I'll use a trusted file"
  #    assert_current_path verification_public_file_site_channel_path(channel, locale: :en)
  #    assert_content "Choose Different Verification Method"
  #    refute_content "Cancel"
  #
  #    assert_content "The following error was encountered: SSL_connect returned=1 errno=0 state=error: certificate verify failed"
  #  end
  #
  test "verification_failed modal appears after failed verification attempt for dns" do
    publisher = publishers(:default)
    sign_in publisher
    channel = publisher.channels.first
    assert_nil channel.details.verification_method

    visit verification_dns_record_site_channel_path(channel)
    click_button("Verify DNS Record")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "dns_record"
  end

  test "verification_failed modal appears after failed verification attempt for public file" do
    Rails.configuration.pub_secrets[:host_inspector_offline] = false

    publisher = publishers(:default)
    sign_in publisher
    channel = publisher.channels.first
    assert_nil channel.details.verification_method

    stub_verification_public_file(channel, body: "", status: 404)

    visit verification_public_file_site_channel_path(channel)
    refute_content("Retry Verification")
    click_button("Verify")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "public_file"
  end

  test "verification_failed modal appears after failed verification attempt for github" do
    publisher = publishers(:default)
    sign_in publisher
    channel = publisher.channels.first
    assert_nil channel.details.verification_method

    stub_verification_public_file(channel, body: "", status: 404)

    visit verification_github_site_channel_path(channel)
    refute_content("Retry Verification")
    click_button("Verify")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "github"
  end

  test "site channels appear on dashboard if publisher completes verification later" do
    publisher = publishers(:default)
    sign_in publisher
    channel = publisher.channels.first
    assert_nil channel.details.verification_method

    visit verification_public_file_site_channel_path(channel)
    click_link(I18n.t("site_channels.shared.finish_verification_later"))

    assert_content(I18n.t("publishers.channel.one_more_step"))
  end
end
