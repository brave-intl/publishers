require "test_helper"

class SiteChannelVerificationTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "Cancel and Choose Different Verification Method buttons only appear in appropriate places" do
    publisher = publishers(:default)
    sign_in publisher

    visit new_site_channel_path
    assert_content "Cancel"

    fill_in "channel_details_attributes_brave_publisher_id_unnormalized", with: "example.com"

    click_button("Continue")
    channel = publisher.channels.order("created_at").last
    assert_current_path verification_choose_method_site_channel_path(channel)
    assert_content "Cancel"

    click_link "I'll use a trusted file"
    assert_current_path verification_public_file_site_channel_path(channel)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"

    visit verification_dns_record_site_channel_path(channel)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"

    visit verification_wordpress_site_channel_path(channel)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"
  end

  test "When bad ssl happens" do
    Rails.application.secrets[:host_inspector_offline] = false

    publisher = publishers(:default)
    sign_in publisher

    visit new_site_channel_path
    assert_content "Cancel"

    fill_in "channel_details_attributes_brave_publisher_id_unnormalized", with: "https://self-signed.badssl.com/"

    click_button("Continue")
    channel = publisher.channels.order("created_at").last
    assert_current_path verification_choose_method_site_channel_path(channel)
    assert_content "Cancel"

    click_link "I'll use a trusted file"
    assert_current_path verification_public_file_site_channel_path(channel)
    assert_content "Choose Different Verification Method"
    refute_content "Cancel"

    assert_content "The following error was encountered: SSL_connect returned=1 errno=0 state=error: certificate verify failed"

    Rails.application.secrets[:host_inspector_offline] = true
  end

  test "verification_failed modal appears after failed verification attempt for all methods" do
    publisher = publishers(:default)
    sign_in publisher
    channel = publisher.channels.first

    assert_nil channel.details.verification_method

    # dns
    visit verification_dns_record_site_channel_path(channel)
    click_button("Verify DNS Record")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "dns_record"

    # public file
    visit verification_public_file_site_channel_path(channel)
    refute_content("Retry Verification")
    click_button("Verify")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "public_file"

    # wordpress
    visit verification_wordpress_site_channel_path(channel)
    refute_content("Retry Verification")
    click_button("Verify")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "wordpress"

    # github
    visit verification_github_site_channel_path(channel)
    refute_content("Retry Verification")
    click_button("Verify")
    assert_content("Retry Verification")
    channel.reload
    assert_equal channel.details.verification_method, "github"
  end
end
