require "test_helper"

class LogInTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "can navigate to log in from landing page" do
    visit root_path
    assert_content page, "Brave Payments"
    click_link('Log In')
    assert_content page, "Log In"
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
end
