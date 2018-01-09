require "test_helper"

class TwoFactorRegistrationsTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "Disabling TOTP prompts for confirmation" do
    publisher = publishers(:verified)
    sign_in publisher

    visit two_factor_registrations_path
    assert_content page, "Enabled"
    refute_content page, "Set Up" # TOTP setup is not available

    click_link('Disable') # Disable TOTP

    assert_content page, "Disable Authenticator App?"

    click_link("Do Not Disable")

    refute_content page, "Disable Authenticator App?"

    click_link('Disable') # Disable TOTP

    assert_content page, "Disable Authenticator App?"

    click_link("Disable it for now")

    assert_content page, "Set Up" # TOTP setup is available
  end

  test "Disabling U2F prompts for confirmation" do
    publisher = publishers(:verified)
    sign_in publisher

    visit two_factor_registrations_path
    assert_content page, "Enabled"
    assert_content page, "My U2F Key" # Key is present
    refute_content page, "No keys have been added" # "No key" warning is not visible

    click_link('Remove') # Disable TOTP

    assert_content page, "Remove Security Key?"

    click_link("Do Not Remove")

    refute_content page, "Remove Security Key?"

    click_link('Remove') # Disable TOTP

    assert_content page, "Remove Security Key?"

    click_link("Remove Security Key")

    refute_content page, "My U2F Key" # Key is not present

    # FIXME: U2F is dark launched, and only appears when you have it enabled
    # or provide params[:u2f]. See issue #442
    # assert_content page, "No keys have been added" # "No key" warning is visible
  end

end
