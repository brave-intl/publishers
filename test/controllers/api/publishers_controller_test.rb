require "test_helper"
require "shared/mailer_test_helper"
require "whois-parser"

class Api::PublishersControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  UNVERIFIED_DOMAIN_PUBLISHER_PARAMS = {
    publisher_type: "domain",
    publisher_id: "default.org"
  }.freeze


  test "#notify_unverified returns 500 when no whois contacts found for domain" do
    contacts = []
    # we can't test this because whois gem does not support
    GetWhoisEmailsForDomain.any_instance.stubs(:perform).returns(contacts)

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: UNVERIFIED_DOMAIN_PUBLISHER_PARAMS)
    end

    assert_equal 500, response.status
    assert_match "No contacts listed on whois info for 'default.org'", response.body
  end

  test "#notify_unverified returns 500 when contact found but email blank" do
    contacts = [Whois::Parser::Contact.new(email: "")]
    GetWhoisEmailsForDomain.any_instance.stubs(:perform).returns(contacts)

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: UNVERIFIED_DOMAIN_PUBLISHER_PARAMS)
    end

    assert_equal 500, response.status
    assert_match "No valid emails found on whois info for 'default.org'", response.body
  end

  test "#notify_unverified returns 500 when contact found but email malformed" do
    contacts = [Whois::Parser::Contact.new(email: "default.org")]
    GetWhoisEmailsForDomain.any_instance.stubs(:perform).returns(contacts)

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: UNVERIFIED_DOMAIN_PUBLISHER_PARAMS)
    end

    assert_equal 500, response.status
    assert_match "No valid emails found on whois info", response.body
  end

  test "#notify_unverified returns 200 when valid whois contacts found, sends emails" do
    admin_contact = Whois::Parser::Contact.new(email: "admin@default.org")
    tech_contact = Whois::Parser::Contact.new(email: "tech@default.org")
    contacts = [admin_contact, tech_contact]
    GetWhoisEmailsForDomain.any_instance.stubs(:perform).returns(contacts)

    # enqueue 2 emails for both valid addresses
    assert_enqueued_emails 4 do
      post(notify_unverified_api_publishers_path, params: UNVERIFIED_DOMAIN_PUBLISHER_PARAMS)
    end

    assert_equal 200, response.status
  end

  test "#notify_unverified returns 400 when invalid publisher type given" do
    # verify returns 400 if publisher_type is unknown
    invalid_publisher_params = {
        publisher_type: "medium",
        publisher_id: "medium.com/alice"
    }

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: invalid_publisher_params)
    end

    assert_equal 400, response.status
    assert_match "medium is an invalid publisher type", response.body

    # verify returns 400 if only publisher_type is supplied and not the domain
    invalid_publisher_params = {
        publisher_type: "domain",
        publisher_id: ""
    }

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: invalid_publisher_params)
    end

    assert_equal 400, response.status

    # verify returns 400 if no params are supplied
    invalid_publisher_params = {}

    assert_enqueued_emails 0 do
      post(notify_unverified_api_publishers_path, params: invalid_publisher_params)
    end

    assert_equal 400, response.status
  end
end
