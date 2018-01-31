require "test_helper"

class PublishersHomeTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "land page renders, can navigate to log in" do
    visit root_path
    assert_content page, "Brave Payments"
    click_link('Log In')
    assert_content page, "Log In"
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

    # Ensure that form has been reset and can be resubmitted

    click_link('Edit Contact')

    new_name = 'Thomas the Tank Engine'
    fill_in 'update_contact_name', with: new_name

    click_button('Update')

    assert_content page, new_name
    refute_content 'Update'
  end

  test "publishers page renders, unverified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_verify)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    click_link('Remove')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    refute_content page, channel.publication_title
  end

  test "publishers page renders, verified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    click_link('Remove Channel')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    refute_content page, channel.publication_title
  end
end
