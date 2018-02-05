require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PublishersHelper

  SIGNUP_PARAMS = {
    email: "alice@example.com"
  }

  COMPLETE_SIGNUP_PARAMS = {
    publisher: {
      name: "Alice the Pyramid",
      visible: true
    }
  }.freeze

  test "can create a Publisher registration, pending email verification" do
    assert_difference("Publisher.count") do
      # Confirm email + Admin notification
      assert_enqueued_emails(2) do
        post(publishers_path, params: SIGNUP_PARAMS)
      end
    end
    assert_redirected_to(create_done_publishers_path)
    publisher = Publisher.order(created_at: :asc).last
    get(publisher_path(publisher))
    assert_redirected_to(root_path)
  end

  test "can sign up with an existing email, which will send a login email" do
    assert_no_difference("Publisher.count") do
      # Login email should be generated
      assert_enqueued_emails(1) do
        post(publishers_path, params: { email: "alice@verified.org" })
      end
    end
    assert_response :success
    assert_template :create_auth_token
  end

  test "sends an email with an access link" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
      publisher = Publisher.order(created_at: :asc).last
      email = ActionMailer::Base.deliveries.find do |message|
        message.to.first == SIGNUP_PARAMS[:email]
      end
      assert_not_nil(email)
      url = publisher_url(publisher, token: publisher.authentication_token)
      assert_email_body_matches(matcher: url, email: email)
    end
  end

  test "re-used access link is rejected and send publisher to the expired auth token page" do
    publisher = publishers(:completed)
    url = publisher_url(publisher, token: publisher.authentication_token)

    get url
    assert_redirected_to home_publishers_url, "precond - publisher is logged in"

    get url
    assert_redirected_to expired_auth_token_publishers_path(publisher_id: publisher.id), "re-used URL is rejected, publisher not logged in"
  end

  test "expired login link takes unverified publishers to dashboard" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last

    # expire token and attempt to cliam
    publisher.authentication_token_expires_at = Time.now
    publisher.save
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)

    # verify that publisher attempt to claim expired token returns expired token page
    assert_redirected_to expired_auth_token_publishers_path(publisher_id: publisher.id)
    follow_redirect!

    # verify that publisher is then redirect to root
    assert_redirected_to root_path
  end

  test "expired login link takes verified publishers to expired auth token page" do
    publisher = publishers(:verified)

    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)

    # expire the token and attempt to claim
    publisher.authentication_token_expires_at = Time.now
    publisher.save
    get(url)

    # verify that verified publishers are taken to expired token page
    assert_redirected_to expired_auth_token_publishers_path(publisher_id: publisher.id)
    follow_redirect!

    # verify publisher is not redirected to homepage
    assert_response :success
  end

  test "expired session redirects to login page" do
    # login the publisher
    publisher = publishers(:completed)
    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    get(url)

    # assert redirected to dashboard
    assert_redirected_to home_publishers_path

    # fast forward time to simulate timeout
    travel 1.day do
      publisher.save!
      publisher.reload
      get(home_publishers_path)
    end

    # verify publisher is redirected to login page
    assert_redirected_to new_auth_token_publishers_path
  end

  test "an unauthenticated html request redirects to home" do
    get home_publishers_path
    assert_response 302
  end

  test "an unauthenticated json request returns a 401" do
    get home_publishers_path, headers: { 'HTTP_ACCEPT' => "application/json" }
    assert_response 401
  end

  def request_login_email(publisher:)
    perform_enqueued_jobs do
      get(new_auth_token_publishers_path)
      params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id email)) }
      post(create_auth_token_publishers_path, params: params)
    end
  end

  test "relogin sends a login link email" do
    publisher = publishers(:default)
    request_login_email(publisher: publisher)
    email = ActionMailer::Base.deliveries.find do |message|
      message.to.first == publisher.email
    end
    assert_not_nil(email)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    assert_email_body_matches(matcher: url, email: email)
  end

  test "relogin email works only once" do
    publisher = publishers(:default)
    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    get(url)
    follow_redirect!
    assert_select("span.email", publisher.email)
    sign_out(:publisher)
    get(url)
    assert_empty(css_select("span.email"))
  end

  # test "relogin for unverified publishers requires email" do
  #   publisher = publishers(:default)
  #   assert_enqueued_jobs(0) do
  #     get(new_auth_token_publishers_path)
  #     params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id)) }
  #     post(create_auth_token_publishers_path, params: params)
  #   end
  # end
  #
  # test "relogin for unverified publishers fails with the wrong email" do
  #   publisher = publishers(:default)
  #   assert_enqueued_jobs(0) do
  #     get(new_auth_token_publishers_path)
  #     params = { publisher: { "brave_publisher_id" => publisher.brave_publisher_id, "email" => "anon@cock.li" } }
  #     post(create_auth_token_publishers_path, params: params)
  #   end
  # end
  #
  # test "relogin for verified publishers without an email sends to the publisher's email" do
  #   publisher = publishers(:verified)
  #   perform_enqueued_jobs do
  #     get(new_auth_token_publishers_path)
  #     params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id)) }
  #     post(create_auth_token_publishers_path, params: params)
  #   end
  #   email = ActionMailer::Base.deliveries.find do |message|
  #     message.to.first == publisher.email
  #   end
  #   assert_not_nil(email)
  #   url = publisher_url(publisher, token: publisher.reload.authentication_token)
  #   assert_email_body_matches(matcher: url, email: email)
  # end

  test "publisher completing signup will agree to TOS" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!

    publisher.reload

    refute publisher.agreed_to_tos.present?

    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    publisher.reload

    assert publisher.agreed_to_tos.present?
  end

  test "publisher updating contact email address will trigger 3 emails and allow publishers confirm new address" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    # verify two emails (one internal) have been sent
    assert ActionMailer::Base.deliveries.count == 2

    # update the publisher email
    perform_enqueued_jobs do
      patch(publishers_path,
            params: { publisher: {pending_email: 'alice-pending@example.com' } },
            headers: { 'HTTP_ACCEPT' => "application/json" })
    end

    publisher.reload

    # verify pending email has been updated
    assert_equal 'alice-pending@example.com', publisher.pending_email

    # verify original email still is used
    assert_equal 'alice@example.com', publisher.email

    # verify 3 emails have been sent after update
    assert ActionMailer::Base.deliveries.count == 5

    # verify notification email sent to original address
    email = ActionMailer::Base.deliveries.find do |message|
      message.to == publisher.email
      message.subject == I18n.t('publisher_mailer.notify_email_change.subject', publication_title: publisher.name)
    end
    assert_not_nil(email)

    # verify brave gets an internal email copy of confirmation email
    email = ActionMailer::Base.deliveries.find do |message|
      message.to.first == Rails.application.secrets[:internal_email]
      message.subject == "<Internal> #{I18n.t('publisher_mailer.confirm_email_change.subject', publication_title: publisher.name)}"
    end
    assert_not_nil(email)

    # verify confirmation email sent to pending address
    email = ActionMailer::Base.deliveries.find do |message|
      message.to == publisher.pending_email
      message.subject == I18n.t('publisher_mailer.confirm_email_change.subject', publication_title: publisher.name)
    end
    assert_not_nil(email)

    url = publisher_url(publisher, confirm_email: publisher.pending_email, token: publisher.authentication_token)
    get(url)
    publisher.reload

    # verify email changes after confirmation
    assert_equal('alice-pending@example.com', publisher.email)

    # verify pending email is removed after confirmation
    assert_nil(publisher.pending_email)
  end

  test "after verification, a publisher's `uphold_state_token` is set and will be used for Uphold authorization" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    # skip 2FA prompt
    publisher.two_factor_prompted_at = 1.day.ago
    publisher.save!

    # verify that the state token has not yet been set
    assert_nil(publisher.uphold_state_token)

    # move right to `dashboard`
    url = home_publishers_url
    get(url)

    # verify that a state token has been set
    publisher.reload
    assert_not_nil(publisher.uphold_state_token)

    # assert that the state token is included in the uphold authorization url
    endpoint = Rails.application.secrets[:uphold_authorization_endpoint]
                   .gsub('<UPHOLD_CLIENT_ID>', Rails.application.secrets[:uphold_client_id])
                   .gsub('<UPHOLD_SCOPE>', Rails.application.secrets[:uphold_scope])
                   .gsub('<STATE>', publisher.uphold_state_token)

    assert_select("a[href='#{endpoint}']") do |elements|
      assert_equal(1, elements.length, 'A link with the correct href to Uphold.com is present')
    end
  end

  test "after redirection back from uphold and uphold_api is offline, a publisher's code is still set" do
    begin
      perform_enqueued_jobs do
        post(publishers_path, params: SIGNUP_PARAMS)
      end
      publisher = Publisher.order(created_at: :asc).last
      url = publisher_url(publisher, token: publisher.authentication_token)
      get(url)
      follow_redirect!
      perform_enqueued_jobs do
        patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
      end

      uphold_state_token = SecureRandom.hex(64)
      publisher.uphold_state_token = uphold_state_token

      publisher.save!

      uphold_code = 'ebb18043eb2e106fccb9d13d82bec119d8cd016c'

      stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
          .with(body: "code=#{uphold_code}&grant_type=authorization_code")
          .to_timeout

      url = uphold_verified_publishers_path
      get(url, params: { code: uphold_code, state: uphold_state_token })
      assert(200, response.status)
      publisher.reload

      # verify that the uphold_state_token has been cleared
      assert_nil(publisher.uphold_state_token)

      # verify that the uphold_code has been set
      assert_not_nil(publisher.uphold_code)
      assert_equal('ebb18043eb2e106fccb9d13d82bec119d8cd016c', publisher.uphold_code)

      # verify that the uphold_access_parameters has not been set
      assert_nil(publisher.uphold_access_parameters)

      # verify that the finished_header was not displayed
      refute_match(I18n.t('publishers.finished_header'), response.body)
    end
  end

  test "after redirection back from uphold and uphold_api is online, a publisher's code is nil and uphold_access_parameters is set" do
    begin
      perform_enqueued_jobs do
        post(publishers_path, params: SIGNUP_PARAMS)
      end
      publisher = Publisher.order(created_at: :asc).last
      url = publisher_url(publisher, token: publisher.authentication_token)
      get(url)
      follow_redirect!
      perform_enqueued_jobs do
        patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
      end

      uphold_code = 'ebb18043eb2e106fccb9d13d82bec119d8cd016c'
      uphold_state_token = SecureRandom.hex(64)
      publisher.uphold_state_token = uphold_state_token

      publisher.save!

      stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
          .with(body: "code=#{uphold_code}&grant_type=authorization_code")
          .to_return(status: 201, body: "{\"access_token\":\"FAKEACCESSTOKEN\",\"token_type\":\"bearer\",\"refresh_token\":\"FAKEREFRESHTOKEN\",\"scope\":\"cards:write\"}")

      url = uphold_verified_publishers_path
      get(url, params: { code: uphold_code, state: uphold_state_token })
      assert(200, response.status)

      publisher.reload
      # verify that the uphold_state_token has been cleared
      assert_nil(publisher.uphold_state_token)

      # verify that the uphold_code has been cleared
      assert_nil(publisher.uphold_code)

      # verify that the uphold_access_parameters has been set
      assert_match('FAKEACCESSTOKEN', publisher.uphold_access_parameters)

      assert_redirected_to '/publishers/home'
    end
  end

  test "after redirection back from uphold, a missing publisher's `uphold_state_token` redirects back to home" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    publisher.two_factor_prompted_at = 1.day.ago
    publisher.save!

    url = uphold_verified_publishers_path
    get(url, params: { code: 'ebb18043eb2e106fccb9d13d82bec119d8cd016c' })
    assert_redirected_to '/publishers/home'

    # Check that failure message is displayed
    follow_redirect!
    assert_match(I18n.t("publishers.uphold_verified.uphold_error"), response.body)
  end

  test "after redirection back from uphold, a mismatched publisher's `uphold_state_token` redirects back to home" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    uphold_state_token = SecureRandom.hex(64)
    publisher.uphold_state_token = uphold_state_token

    publisher.two_factor_prompted_at = 1.day.ago
    publisher.save!

    spoofed_uphold_state_token = SecureRandom.hex(64)
    url = uphold_verified_publishers_path
    get(url, params: { code: 'ebb18043eb2e106fccb9d13d82bec119d8cd016c', state: spoofed_uphold_state_token })
    assert_redirected_to '/publishers/home'

    # Check that failure message is displayed
    follow_redirect!
    assert_match(I18n.t("publishers.uphold_verified.uphold_error"), response.body)
  end

  test "when uphold fails to return uphold_access_parameters, publisher has option to reconnect with uphold" do
    publisher = publishers(:completed)

    # sign in publisher
    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    get(url)

    # give pub uphold state token
    uphold_state_token = SecureRandom.hex(64)
    publisher.uphold_state_token = uphold_state_token
    expected_uphold_code = 'ebb18043eb2e106fccb9d13d82bec119d8cd016c'
    publisher.save

    # simulate return to homepage after creating wallet on uphold.com
    # simulate failed response from uphold.com to get access params
    stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
      .with(body: "code=#{expected_uphold_code}&grant_type=authorization_code")
      .to_timeout
    url = uphold_verified_publishers_path
    get(url, params: { code: expected_uphold_code, state: uphold_state_token })
    follow_redirect!

    # verify uphold :code_acquired but not :access params
    assert_equal publisher.reload.uphold_status, :code_acquired

    # verify message tells publisher they need to reconnect
    assert_select("div#publisher_status.uphold_processing") do |element|
      assert_equal element.text, I18n.t("helpers.publisher.uphold_status.processing")
    end

    # verify button says 'reconnect to uphold' not 'create uphold wallet'
    assert_select("[data-test=reconnect-button]") do |element|
      assert_equal element.text, I18n.t("helpers.publisher.reconnect_to_uphold")
    end
  end

  test "a publisher's statement can be generated via ajax" do
    perform_enqueued_jobs do
      post(publishers_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    url = generate_statement_publishers_path
    patch(url,
          params: { statement_period: 'all' },
          headers: { 'HTTP_ACCEPT' => "application/json" })

    publisher_statement = PublisherStatement.order(created_at: :asc).last

    assert_response 200
    assert_match(
      '{"id":"' + publisher_statement.id + '",' +
        '"date":"' + publisher_statement.created_at.strftime('%B %e, %Y') + '",' +
        '"period":"All"}',
      response.body)
    # assert_match("{\"id\":\"#{publisher_statement.id}\"}", response.body)
  end

  test "a publisher's balance can be polled via ajax" do
    publisher = publishers(:uphold_connected)
    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    get(url)
    follow_redirect!

    url = balance_publishers_path
    get(url,
        headers: { 'HTTP_ACCEPT' => "application/json" })

    assert_response 200
    assert_equal(
        '{"bat_amount":"38077.50","converted_balance":"Approximately 9001.00 USD"}',
        response.body)
  end

  test "home redirects to 2FA prompt on first visit" do
    publisher = publishers(:unprompted)

    sign_in publisher
    get home_publishers_path

    assert_redirected_to prompt_two_factor_registrations_path, "redirects on first visit"
    follow_redirect!

    get home_publishers_path
    assert_response :success
  end
end
