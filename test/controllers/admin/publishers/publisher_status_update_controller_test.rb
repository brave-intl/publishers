require 'test_helper'
require "webmock/minitest"

class Admin::Publishers::PublisherStatusUpdateControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

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

  test "sends email if suspended and send_email flag is set" do
    admin = publishers(:admin)
    sign_in admin
    publisher = publishers(:uphold_connected)

    assert_enqueued_jobs(1) do    
      post(
        admin_publisher_publisher_status_updates_path(
          publisher_id: publisher.id,
          publisher_status: PublisherStatusUpdate::SUSPENDED,
          send_email: "true"
        )
      )
    end

    assert publisher.last_status_update, PublisherStatusUpdate::SUSPENDED
  end

  test "does not send email if suspended and send_email flag is set" do
    admin = publishers(:admin)
    sign_in admin
    publisher = publishers(:uphold_connected)
    assert_enqueued_jobs(0) do    
      post(
        admin_publisher_publisher_status_updates_path(
          publisher_id: publisher.id,
          publisher_status: PublisherStatusUpdate::SUSPENDED,
        )
      )
    end
  end
end
