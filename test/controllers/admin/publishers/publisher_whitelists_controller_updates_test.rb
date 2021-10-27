require "test_helper"
require "webmock/minitest"

class Admin::Publishers::PublisherWhitelistUpdatesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  before do
    admin = publishers(:admin)
    sign_in admin
  end

  test "#create adds a whitelist" do
    admin = publishers(:admin)
    sign_in admin
    publisher = publishers(:uphold_connected)
    note = "whitelisting after review."

    assert publisher.last_whitelist_update.nil?

    post(
      admin_publisher_publisher_whitelist_updates_path(
        publisher_id: publisher.id
      ),
      params: {note: note, enable: true}
    )

    refute publisher.last_whitelist_update.nil?
    assert_equal publisher.last_whitelist_update.publisher_note.note, note
    assert_equal publisher.last_whitelist_update.enabled, true

    post(
      admin_publisher_publisher_whitelist_updates_path(
        publisher_id: publisher.id
      ),
      params: {note: note, enable: false}
    )

    assert_equal publisher.last_whitelist_update.enabled, false
    assert_equal publisher.whitelist_updates.count, 2
  end
end
