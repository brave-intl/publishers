require "test_helper"
require "shared/mailer_test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper

  PUBLISHER_PARAMS = {
    publisher: {
      email: "alice@example.com",
      brave_publisher_id: "pyramid.net",
      name: "Alice the Pyramid",
      phone: "+14159001420"
    }
  }.freeze

  test "new action has a create form" do
    get(new_publisher_path)
    assert_response(:success)
    assert_select("form[action=\"#{publishers_path}\"]")
  end

  test "can create a Publisher registration, pending email verification" do
    get(new_publisher_path)
    assert_difference("Publisher.count") do
      # Confirm email + Admin notification
      assert_enqueued_emails(2) do
        post(publishers_path, params: PUBLISHER_PARAMS)
      end
    end
    assert_redirected_to(create_done_publishers_path)
    get(publisher_path(Publisher.last))
    assert_redirected_to(root_path)
  end

  test "sends an email with an access link" do
    perform_enqueued_jobs do
      post(publishers_path, params: PUBLISHER_PARAMS)
      publisher = Publisher.last
      email = ActionMailer::Base.deliveries.find do |message|
        message.to.first == PUBLISHER_PARAMS[:publisher][:email]
      end
      assert_not_nil(email)
      url = publisher_url(publisher, token: publisher.authentication_token)
      assert_email_body_matches(matcher: url, email: email)
    end
  end

  test "access link logs the user in" do
    post(publishers_path, params: PUBLISHER_PARAMS)
    publisher = Publisher.last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    assert_select("[data-test-id='current_publisher']", publisher.to_s)
  end
end
