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
end