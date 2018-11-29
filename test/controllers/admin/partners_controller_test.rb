require 'test_helper'
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::PartnersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  after do
    clear_enqueued_jobs
  end

  test "admin can access partners" do
    admin = publishers(:admin)
    sign_in admin

    get new_admin_partner_path
    assert_response :success
  end

  test "when there's an unverified existing publisher" do
    admin = publishers(:admin)
    sign_in admin
    unverified_email = 'unverified@example.com'

    publisher = Publisher.find_or_create_by(pending_email: unverified_email)

    # Ensure it's a publisher
    assert_equal publisher.role, Publisher::PUBLISHER

    # Make request
    assert_enqueued_emails(1) do
      post admin_partners_path, params: { email: unverified_email }
    end

    # We assert that only one account is created
    assert_empty Publisher.where(email: unverified_email)
    # We made it a partner
    assert Publisher.find_by(pending_email: unverified_email).partner?
  end

  test "when there's a verified existing publisher" do
    admin = publishers(:admin)
    sign_in admin
    unverified_email = 'unverified@example.com'

    # ensure there are no previously existing entries in the database
    Publisher.where(pending_email: unverified_email).destroy_all
    publisher = Publisher.find_or_create_by(email: unverified_email)

    # Ensure it's a publisher
    assert_equal publisher.role, Publisher::PUBLISHER

    # Make request
    assert_enqueued_emails(1) do
      post admin_partners_path, params: { email: unverified_email }
    end

    # We assert that only one account is created
    assert_empty Publisher.where(pending_email: unverified_email)
    # We made it a partner
    assert Publisher.find_by(email: unverified_email).partner?
  end

  test "when there's a new partner" do
    admin = publishers(:admin)
    sign_in admin
    partner_email = 'partner@example.com'

    # Make request
    assert_enqueued_emails(1) do
      post admin_partners_path, params: { email: partner_email }
    end

    # We made it a partner
    assert Partner.find_by(email: partner_email).partner?
  end

  test "when the email is already a partner" do
    admin = publishers(:admin)
    sign_in admin
    partner_email = "partner@completed.org"

    # Make request
    assert_enqueued_emails(0) do
      post admin_partners_path, params: { email: partner_email }
    end

    assert_equal "Email is already a partner", flash[:alert]
    assert_template :new
  end
end
