require "test_helper"

class SignUpTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "can navigate to sign up from landing page" do
    visit root_path
    assert_content page, "Brave Rewards"
    click_link("Get Started")
    assert_content page, "Join Brave Rewards"
  end

  test "new users are prompted to finish setting up their account and 2FA" do
    name = "Some name"
    publisher = publishers(:unprompted)
    sign_in publisher

    visit email_verified_publishers_path

    assert_content page, "Finish signing up"

    fill_in "publisher_name", with: name
    click_button("Sign Up")

    assert_current_path(prompt_two_factor_registrations_path)
    click_link("Skip for now")

    assert_current_path(home_publishers_path)
  end

  test "a user can resend a log in email" do
    email = "unique@verified.org"
    assert Publisher.where(email: email).count == 0  # ensure we don't send log in link

    visit sign_up_publishers_path
    assert_content page, "Join Brave Rewards"
    fill_in "email", with: email

    click_button("Get Started")
    assert_content page, "An email is on its way! We just sent an access link to #{email}"

    assert_enqueued_emails(2) do
      click_link('try again')
    end
  end
end
