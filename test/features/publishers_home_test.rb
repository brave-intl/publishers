require "test_helper"

class PublishersHomeTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "land page renders, can navigate to log in" do
    visit root_path
    assert_content page, "Brave Payments"
    click_link('Log in')
    assert_content page, "Log in to Brave Payments"
  end

  test "publishers page renders, 'edit contact' opens form, name can be changed" do
    publisher = publishers(:completed)
    sign_in publisher

    visit home_publishers_path
    assert_content page, publisher.name
    assert_content page, publisher.email

    click_link('Edit Contact')

    new_name = 'Bob the Builder'
    fill_in 'update_contact_name', with: new_name

    click_button('Update')

    assert_content page, new_name
    refute_content 'Update'
  end

end
