require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include Rails.application.routes.url_helpers
  include MockRewardsResponses

  before do
    stub_rewards_parameters
  end

  test "can navigate to sign up from landing page" do
    visit root_path
    assert_content page, "Earn for your online content"
    click_link("sign up")
    assert_content page, "Create account"
  end

  test "new users are prompted to finish setting up their account and 2FA" do
    name = "Some name"
    publisher = publishers(:unprompted)
    sign_in publisher

    visit email_verified_publishers_path

    assert_content page, "Finish signing up"

    fill_in "publisher_name", with: name
    click_button("Sign Up")

    assert_current_path(prompt_security_publishers_path(locale: :en))
    click_link("Skip for now")

    assert_current_path(home_publishers_path(locale: :en))
  end

  test "new users can register Yubikey" do
    name = "Some name"
    publisher = publishers(:unprompted)
    sign_in publisher

    visit email_verified_publishers_path

    assert_content page, "Finish signing up"

    fill_in "publisher_name", with: name
    click_button("Sign Up")

    assert_current_path(prompt_security_publishers_path(locale: :en))
    click_link("Set Up 2FA")
    click_link("Add Key")
    assert_content page, "Register Security Key"
  end

  test "a user can resend a log in email" do
    email = "unique@verified.org"
    assert Publisher.where(email: email).count == 0 # ensure we don't send log in link

    visit sign_up_path
    assert_content page, "Create account"
    fill_in "email", with: email

    click_button("Create account")

    # TODO: We'll add this functionality :)
    # assert_content page, "An email is on its way! We just sent an access link to #{email}"

    # assert_enqueued_emails(2) do
    #   click_link('try again')
    # end
  end

  test "malformed input doesn't blow up" do
    visit "/publishers/sign_up?locale=%E0%80%A2%E0%80%A7%E0%80%A2b155b3be"

    assert_content "Join Brave Creators"
  end
end
