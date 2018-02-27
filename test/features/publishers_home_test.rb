require "test_helper"

class PublishersHomeTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers

  test "name can be changed using 'edit contact' form" do
    active_promo_id_original = Rails.application.secrets[:active_promo_id]
    Rails.application.secrets[:active_promo_id] = ""
    publisher = publishers(:completed)
    sign_in publisher

    # Turn off promo
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
    Rails.application.secrets[:active_promo_id] = active_promo_id_original
  end

  test "email can be changed using 'edit contact' form" do
    publisher = publishers(:completed)
    sign_in publisher

    visit home_publishers_path
    assert_content page, publisher.name
    assert_content page, publisher.email

    original_email = publisher.email
    new_email = 'jane.doe@example.com'

    # Update email. A "pending" change message should be displayed.
    click_link 'Edit Contact'
    fill_in 'update_contact_email', with: new_email
    click_button 'Update'

    assert_content page, 'Pending: Email address has been updated to: ' + new_email
    refute_content 'Update'

    # Let's change it back to the original. The "pending" message should be removed.
    click_link 'Edit Contact'
    fill_in 'update_contact_email', with: original_email
    click_button 'Update'

    refute_content page, 'Pending: Email address has been updated'
  end

  test "unverified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_verify)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    find("#channel_row_#{channel.id}").click_link('Remove Channel')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    refute_content page, channel.publication_title
  end

  test "verified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    find("#channel_row_#{channel.id}").click_link('Remove Channel')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    refute_content page, channel.publication_title
  end

  test "website channel type can be chosen" do
    publisher = publishers(:completed)
    sign_in publisher

    # Turn off promo
    visit home_publishers_path

    click_link('+ Add Channel')

    assert_content page, 'Add Channel'
    assert_content page, 'WEBSITE'
    assert_content page, 'YOUTUBE CHANNEL'

    find('[data-test-choose-channel-website]').click

    assert_current_path(new_site_channel_path)
  end
end
