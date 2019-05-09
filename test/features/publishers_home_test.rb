require "test_helper"

class PublishersHomeTest < Capybara::Rails::TestCase
  include Devise::Test::IntegrationHelpers
  include EyeshadeHelper

  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  test "name can be changed using 'edit contact' form" do
    publisher = publishers(:completed)
    sign_in publisher

    visit home_publishers_path
    assert_content page, publisher.name
    assert_content page, publisher.email

    click_link('Edit Contact')

    new_name = 'Bob the Builder'
    fill_in 'update_contact_name', with: new_name

    click_button('Update')
    wait_until { !page.find('.cssload-container', visible: :all).visible? }

    assert_content page, new_name
    refute_content 'Update'

    # Ensure that form has been reset and can be resubmitted
    click_link('Edit Contact')

    new_name = 'Thomas the Tank Engine'
    fill_in 'update_contact_name', with: new_name

    click_button('Update')
    wait_until { !page.find('.cssload-container', visible: :all).visible? }

    assert_content page, new_name
    refute_content 'Update'
  end

  test "email can be changed using 'edit contact' form" do
    publisher = publishers(:completed)
    sign_in publisher

    visit home_publishers_path
    assert_content publisher.name
    assert_content publisher.email

    original_email = publisher.email
    new_email = 'jane.doe@example.com'

    # Update email. A "pending" change message should be displayed.
    click_link 'Edit Contact'
    fill_in 'update_contact_email', with: new_email
    click_button 'Update'

    wait_until { !page.find('.cssload-container', visible: :all).visible? }

    assert_content "Pending: Email address has been updated to: #{new_email}"
    refute_content 'Update'

    page.evaluate_script 'window.location.reload()' # Refresh to remove spinner overlay to make button visible
    # Let's change it back to the original. The "pending" message should be removed.
    click_link 'Edit Contact'
    fill_in 'update_contact_email', with: original_email
    click_button 'Update'

    refute_content page, 'Pending: Email address has been updated'
  end

  # TODO Uncomment when channel removal is enabled
  # test "unverified channel can be removed after confirmation" do
  #   publisher = publishers(:small_media_group)
  #   channel = channels(:small_media_group_to_verify)

  #   sign_in publisher
  #   visit home_publishers_path

  #   assert_content page, channel.publication_title
  #   find("#channel_row_#{channel.id}").click_link('Remove Channel')
  #   assert_content page, "Are you sure you want to remove this channel?"
  #   find('[data-test-modal-container]').click_link("Remove Channel")
  #   refute_content page, channel.publication_title
  # end

  test "verified channel can be removed after confirmation" do
    publisher = publishers(:small_media_group)
    channel = channels(:small_media_group_to_delete)

    sign_in publisher
    visit home_publishers_path

    assert_content page, channel.publication_title
    find("#channel_row_#{channel.id}").click_link('Remove Channel')
    assert_content page, "Are you sure you want to remove this channel?"
    find('[data-test-modal-container]').click_link("Remove Channel")
    wait_until { !page.find('.cssload-container', visible: :all).visible? }
    refute_content channel.publication_title
  end

  test "website channel type can be chosen" do
    publisher = publishers(:completed)
    sign_in publisher
    visit home_publishers_path

    click_link('+ Add Channel', match: :first)

    assert_content page, 'Add Channel'
    assert_content page, 'WEBSITE'
    assert_content page, 'YOUTUBE CHANNEL'

    find('[data-test-choose-channel-website]').click

    assert_current_path(new_site_channel_path)
  end

  test "javascript_last_detected_at is updated when visiting the dashboard" do
    publisher = publishers(:completed)
    assert_nil publisher.javascript_last_detected_at

    sign_in publisher
    visit home_publishers_path

    wait_until { publisher.reload.javascript_last_detected_at != nil }
  end

  test "confirm default currency modal appears after uphold signup" do
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    visit home_publishers_path
    assert_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "confirm default currency modal does not appear for non uphold verified publishers" do
    publisher = publishers(:uphold_connected)
    sign_in publisher

    visit home_publishers_path
    refute_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "confirm default currency modal does not appear for non uphold authorized publishers" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    wallet = { "wallet" => { "authorized" => false }}
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    visit home_publishers_path
    refute_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
  end

  test "dashboard can still load even when publisher's wallet cannot be fetched from eyeshade" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    wallet = { "wallet" => { "authorized" => false } }
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)
    visit home_publishers_path

    assert publisher.wallet.present?
    assert_content page, publisher.name
  end

  test "dashboard can still load even when publisher's balance cannot be fetched from eyeshade" do
    begin
      prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:uphold_connected)
      sign_in publisher

      wallet = { "wallet" => { "authorized" => false } }
      balances = "go away\nUser-agent: *\nDisallow:"

      stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet, balances: balances)

      visit home_publishers_path

      refute publisher.wallet.present?
      assert_content page, publisher.name
      assert_content page, "Unavailable"
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end
end
