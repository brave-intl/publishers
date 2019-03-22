require "test_helper"

class LogInTest < Capybara::Rails::TestCase
  include ActionMailer::TestHelper
  include Devise::Test::IntegrationHelpers

  def canned_u2f_response(registration)
    return ActiveSupport::JSON.encode({
                                        keyHandle: registration.key_handle,
                                        clientData: "eyJ0eXAiOiJuYXZpZ2F0b3IuaWQuZ2V0QXNzZXJ0aW9uIiwiY2hhbGxlbmdlIjoiMEVxTHk3TExoYWQyVVN1Wk9ScWRqZThsdG9VWHZQVUU5aHQyRU5sZ2N5VSIsIm9yaWdpbiI6Imh0dHBzOi8vbG9jYWxob3N0OjMwMDAiLCJjaWRfcHVia2V5IjoidW51c2VkIn0",
                                        signatureData: "AQAAAAowRQIgfFLvGl1joGFlmZKPgIkimfJGt5glVEdiUYDtF8olMJgCIQCHIMR9ofM7VE7U6xURkDce8boCHwLq-vyVB9rWcKcscQ"
                                      })
  end

  test "can navigate to log in from landing page" do
    visit root_path
    assert_content page, "Brave Rewards"
    click_link('Log In')
    assert_content page, "Log In"
  end

  test "a user with an existing email can receive a login email" do
    email = 'alice@verified.org'

    visit new_auth_token_publishers_path

    assert_content page, "Log In"
    fill_in 'publisher_email', with: email
    click_button('Log In')

    assert_content page, "An email is on its way! We just sent an access link to #{email}"
  end

  test "after failed login, user can create an account instead" do
    email = 'new-test@example.com'

    visit new_auth_token_publishers_path

    assert_content page, "Log In"
    fill_in 'publisher_email', with: email
    click_button('Log In')

    assert_content page, "Couldn't find a publisher with that email address"
    click_link("create an account with the email #{email}")

    assert_content page, "An email is on its way"
  end

  test "a user can resend log in email" do
    email = 'alice@verified.org'

    visit new_auth_token_publishers_path

    assert_content page, "Log In"
    fill_in 'publisher_email', with: email
    click_button('Log In')

    assert_enqueued_emails(1) do
      click_link('try again')
    end
  end

  test "a user without 2FA enabled will be taken to the dashboard after log in" do
    publisher = publishers(:completed)
    visit new_auth_token_publishers_path
    assert_content page, "Log In"

    fill_in 'publisher_email', with: publisher.email
    click_button 'Log In'
    visit publisher_path(publisher, token: publisher.reload.authentication_token)
    assert_content page, "PENDING PAYOUTS"
  end

  test "a user with TOTP enabled will be asked for an auth code after log in" do
    publisher = publishers(:verified_totp_only)
    visit new_auth_token_publishers_path
    assert_content page, "Log In"

    fill_in 'publisher_email', with: publisher.email
    click_button 'Log In'
    visit publisher_path(publisher, token: publisher.reload.authentication_token)
    assert_content page, "Two-factor Authentication"
    assert_content page, "Enter the authentication code from your mobile app to verify your identity."

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(Time.now.to_i)

    fill_in 'totp_password', with: '123456'
    click_button 'Verify'
    assert_content page, "PENDING PAYOUTS"
  end

  test "a user with TOTP enabled can retry entry of their auth code" do
    publisher = publishers(:verified_totp_only)
    visit new_auth_token_publishers_path
    assert_content page, "Log In"

    fill_in 'publisher_email', with: publisher.email
    click_button 'Log In'
    visit publisher_path(publisher, token: publisher.reload.authentication_token)
    assert_content page, "Two-factor Authentication"
    assert_content page, "Enter the authentication code from your mobile app to verify your identity."

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(false)
    fill_in 'totp_password', with: 'wrong'
    click_button 'Verify'
    assert_content page, "Invalid 6-digit code. Please try again."

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(Time.now.to_i)
    fill_in 'totp_password', with: '123456'
    click_button 'Verify'
    assert_content page, "PENDING PAYOUTS"
  end

  test "a user with U2F enabled will be asked to insert their U2F device after log in" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)

    visit new_auth_token_publishers_path
    assert_content page, "Log In"

    fill_in 'publisher_email', with: publisher.email
    click_button 'Log In'
    visit publisher_path(publisher, token: publisher.reload.authentication_token)
    assert_content page, "Two-factor Authentication"
    assert_content page, "Insert your security key and press the button on the key when blinking."

    U2fAuthenticationsController.any_instance.stubs(:u2f).returns(mock(:authenticate!))
    u2f_response = canned_u2f_response(u2f_registration)

    # Simulate U2F device usage, which submits the form on success
    page.execute_script("document.querySelector('input[name=\"u2f_response\"]').value = '#{u2f_response}';")
    page.execute_script("document.querySelector('form.js-authenticate-u2f').submit();")
    assert_content page, "PENDING PAYOUTS"
  end

  test "a user with U2F enabled can choose to use TOTP if they don't have their device" do
    publisher = publishers(:verified)
    u2f_registration = u2f_registrations(:default)

    visit new_auth_token_publishers_path
    assert_content page, "Log In"

    fill_in 'publisher_email', with: publisher.email
    click_button 'Log In'
    visit publisher_path(publisher, token: publisher.reload.authentication_token)
    assert_content page, "Two-factor Authentication"
    assert_content page, "Insert your security key and press the button on the key when blinking."

    click_link "Use authentication code instead."

    assert_content page, "Two-factor Authentication"
    assert_content page, "Enter the authentication code from your mobile app to verify your identity."

    ROTP::TOTP.any_instance.stubs(:verify_with_drift_and_prior).returns(Time.now.to_i)

    fill_in 'totp_password', with: '123456'
    click_button 'Verify'
    assert_content page, "PENDING PAYOUTS"
  end
end
