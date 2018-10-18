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

  # TODO Uncomment when channel removal is enabled
  # test "verified channel can be removed after confirmation" do
  #   publisher = publishers(:small_media_group)
  #   channel = channels(:small_media_group_to_delete)

  #   sign_in publisher
  #   visit home_publishers_path

  #   assert_content page, channel.publication_title
  #   find("#channel_row_#{channel.id}").click_link('Remove Channel')
  #   assert_content page, "Are you sure you want to remove this channel?"
  #   find('[data-test-modal-container]').click_link("Remove Channel")
  #   refute_content page, channel.publication_title
  # end

  test "website channel type can be chosen" do
    publisher = publishers(:completed)
    sign_in publisher

    # Turn off promo
    visit home_publishers_path

    find('.navbar').click_link('+ Add Channel')

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
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:uphold_connected_currency_unconfirmed)
      sign_in publisher

      wallet = { "wallet" => { "authorized" => false }}.to_json
      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: wallet, headers: {})

      visit home_publishers_path
      refute_content page, I18n.t("publishers.confirm_default_currency_modal.headline")
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "dashboard can still load even when publisher's wallet cannot be fetched from eyeshade" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:uphold_connected_currency_unconfirmed)
      sign_in publisher

      wallet = { "wallet" => { "authorized" => false } }.to_json
      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 404, headers: {})

      visit home_publishers_path

      assert publisher.wallet.present?
      assert_content page, publisher.name
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "dashboard can still load even when publisher's balance cannot be fetched from eyeshade" do
    prev_api_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false
      publisher = publishers(:uphold_connected)
      sign_in publisher

      wallet = { "wallet" => { "authorized" => false } }.to_json
      stub_request(:get, %r{v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet}).
        with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
        to_return(status: 200, body: wallet, headers: {})

      stub_request(:get, "#{Rails.application.secrets[:api_eyeshade_base_uri]}/v1/accounts/balances?account=publishers%23uuid:1a526190-7fd0-5d5e-aa4f-a04cd8550da8&account=uphold_connected.org&account=twitch%23channel:ucTw&account=twitter%23channel:def456").
        to_return(status: 200, body: "go away\nUser-agent: *\nDisallow:")

      visit home_publishers_path

      refute publisher.wallet.present?
      assert_content page, publisher.name
      assert_content page, "Unavailable"
    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_api_eyeshade_offline
    end
  end

  test "only see instant donation button when part of the whitelist" do
    publisher = publishers(:completed)
    sign_in publisher
    visit home_publishers_path
    refute_content page, "Tipping Banner"

    Rails.application.secrets[:brave_rewards_email_whitelist] = publisher.email
    visit home_publishers_path
    assert_content page, "Tipping Banner"
  end
end
