require 'test_helper'
require "webmock/minitest"

class Admin::Publishers::PublisherStatusUpdateControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'updates the status of the publisher' do
    admin = publishers(:admin)
    sign_in admin
    publisher = publishers(:uphold_connected)

    assert_equal publisher.inferred_status, PublisherStatusUpdate::ACTIVE

    post(
      admin_publisher_publisher_status_updates_path(
        publisher_id: publisher.id,
        publisher_status: PublisherStatusUpdate::SUSPENDED
      ),
      params: {},
      headers: {
        'HTTP_REFERER' => admin_publisher_publisher_status_updates_path(publisher_id: publisher.id)
      }
    )

    assert_equal publisher.status_updates.count, 1
    assert_equal publisher.inferred_status, PublisherStatusUpdate::SUSPENDED

    post admin_publisher_publisher_status_updates_path(publisher_id: publisher.id, publisher_status: PublisherStatusUpdate::ACTIVE), params: {}, headers: {'HTTP_REFERER' => admin_publisher_publisher_status_updates_path(publisher_id: publisher.id) }
    assert_equal publisher.status_updates.count, 2
    assert_equal publisher.inferred_status, PublisherStatusUpdate::ACTIVE
  end
end
