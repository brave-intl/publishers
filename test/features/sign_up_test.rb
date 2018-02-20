require "test_helper"

class SignUpTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "can navigate to sign up from landing page" do
    visit root_path
    assert_content page, "Brave Payments"
    click_link('Get Started')
    assert_content page, "Join Brave Payments"
  end

  test "new users are prompted to finish setting up their account and 2FA" do
    name = 'Some name'
    publisher = publishers(:unprompted)
    sign_in publisher

    visit email_verified_publishers_path

    assert_content page, "Finish signing up"

    fill_in 'publisher_name', with: name
    click_button('Sign Up')

    assert_current_path(prompt_two_factor_registrations_path)
    click_link('Skip for now')

    assert_current_path(home_publishers_path)
  end
end
