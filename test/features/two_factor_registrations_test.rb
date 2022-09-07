# typed: false

require "test_helper"

class TwoFactorRegistrationsTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  test "Disabling TOTP prompts for confirmation, it asks for 2fa" do
    publisher = publishers(:verified)
    sign_in publisher

    visit security_publishers_path
    assert_content page, "Enabled"
    refute_content page, "Set Up" # TOTP setup is not available

    click_link("Disable") # Disable TOTP

    assert_content "Disable Authenticator App?"

    click_link("Do Not Disable")
    wait_until { !page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    refute_content "Disable Authenticator App?"

    click_link("Disable") # Disable TOTP

    wait_until { page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    assert_content page, "Disable Authenticator App?"

    click_link("Disable it for now")
    assert_content page, "Two-factor Authentication\nInsert your security key and press the button on the key when blinking.\nDon't have your security key?\nUse authentication code instead.\nLost your 2-factor-authentication?We can help.\n\nFor information related to account settings, visit our Help Center." # TOTP setup is available
  end

  test "Disabling U2F prompts for confirmation, it asks for 2fa" do
    publisher = publishers(:verified)
    sign_in publisher

    visit security_publishers_path
    assert_content page, "Enabled"
    assert_content page, "My U2F Key" # Key is present
    refute_content page, "No keys have been added" # "No key" warning is not visible

    click_link("Remove") # Disable TOTP

    wait_until { page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    assert_content page, "Remove Security Key?"

    click_link("Do Not Remove")

    wait_until { !page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    refute_content "Remove Security Key?"
    click_link("Remove") # Disable TOTP

    wait_until { page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    assert_content page, "Remove Security Key?"

    click_link("Remove Security Key")

    wait_until { !page.find(".js-shared-modal :first-child", match: :first, visible: :all).visible? }

    refute_content page, "My U2F Key" # Key is not present

    # FIXME: U2F is dark launched, and only appears when you have it enabled
    # or provide params[:u2f]. See issue #442
    assert_content page, "Two-factor Authentication\nInsert your security key and press the button on the key when blinking.\nDon't have your security key?\nUse authentication code instead.\nLost your 2-factor-authentication?We can help.\n\nFor information related to account settings, visit our Help Center." # "No key" warning is visible
  end
end
