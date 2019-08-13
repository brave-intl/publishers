require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PublishersHelper
  include EyeshadeHelper

  before do
    @prev_eyeshade_offline = Rails.application.secrets[:api_eyeshade_offline]
    stub_request(:get, /cards\?q/).to_return(body: [].to_json)
    stub_request(:post, Rails.application.secrets[:uphold_api_uri] + "/v0/me/cards").to_return(body: {id: '123e4567-e89b-12d3-a456-426655440000'}.to_json)
  end

  after do
    Rails.application.secrets[:api_eyeshade_offline] = @prev_eyeshade_offline
  end

  SIGNUP_PARAMS = {
    email: "alice@example.com"
  }

  COMPLETE_SIGNUP_PARAMS = {
    publisher: {
      name: "Alice the Pyramid",
      visible: true
    }
  }.freeze

  test "publisher can access a publisher's dashboard" do
    publisher = publishers(:completed)
    sign_in publisher

    get home_publishers_path
    assert_response :success
  end

  test "admin cannot access a publisher's dashboard" do
    admin = publishers(:admin)
    sign_in admin

    get home_publishers_path
    assert_response 302
  end

  test "suspended publisher visits the page for suspended users" do
    publisher = publishers(:completed)
    sign_in publisher

    # Start off as an active user
    publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE)

    get home_publishers_path
    assert_response 200

    get statements_publishers_path
    assert_response 200

    # Get suspended
    publisher.status_updates.create(status: PublisherStatusUpdate::SUSPENDED)

    get home_publishers_path
    assert_redirected_to(suspended_error_publishers_path)

    get statement_publishers_path
    assert_redirected_to(suspended_error_publishers_path)

    # Go back to active
    publisher.status_updates.create(status: PublisherStatusUpdate::ACTIVE)

    get home_publishers_path
    assert_response 200

    get statements_publishers_path
    assert_response 200
  end

  test "can create a Publisher registration, pending email verification" do
    assert_difference("Publisher.count") do
      # Confirm email + Admin notification
      assert_enqueued_emails(2) do
        post(registrations_path, params: SIGNUP_PARAMS)
      end
    end
    assert_response 200
    assert_template :emailed_authentication_token

    publisher = Publisher.order(created_at: :asc).last
    get(publisher_path(publisher))
    assert_redirected_to(root_path)
  end

  test "can sign up with an existing email, which will send a login email" do
    assert_no_difference("Publisher.count") do
      # Login email should be generated
      assert_enqueued_emails(1) do
        post(registrations_path, params: { email: "alice@verified.org" })
      end
    end
    assert_response :success
    assert_template :emailed_authentication_token
  end

  test "sends an email with an access link" do
    url = nil
    perform_enqueued_jobs do
      post(registrations_path, params: SIGNUP_PARAMS)
      publisher = Publisher.order(created_at: :asc).last
      email = ActionMailer::Base.deliveries.find do |message|
        message.to.first == SIGNUP_PARAMS[:email]
      end
      assert_not_nil(email)
      url = publisher_url(publisher, token: publisher.authentication_token)
      assert_email_body_matches(matcher: url, email: email)
    end

    get url
    assert_redirected_to email_verified_publishers_path
  end

  test "re-used access link is rejected and send publisher to the expired auth token page" do
    publisher = publishers(:completed)
    PublisherTokenGenerator.new(publisher: publisher).perform
    url = publisher_url(publisher, token: publisher.authentication_token)

    get url
    assert_redirected_to home_publishers_url, "precond - publisher is logged in"

    get url
    assert_redirected_to expired_authentication_token_publishers_path(id: publisher.id), "re-used URL is rejected, publisher not logged in"
  end

  test "expired login link takes unverified publishers to renew their login link" do
    perform_enqueued_jobs do
      post(registrations_path, params: SIGNUP_PARAMS)
    end
    publisher = Publisher.order(created_at: :asc).last

    # expire token and attempt to cliam
    publisher.user_authentication_token.authentication_token_expires_at = Time.now
    publisher.user_authentication_token.save
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)

    # verify that publisher attempt to claim expired token returns expired token page
    assert_redirected_to expired_authentication_token_publishers_path(id: publisher.id)
  end

  test "expired login link takes verified publishers to expired auth token page" do
    publisher = publishers(:verified)

    request_login_email(publisher: publisher)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)

    # expire the token and attempt to claim
    publisher.user_authentication_token.authentication_token_expires_at = Time.now
    publisher.user_authentication_token.save
    get(url)

    # verify that verified publishers are taken to expired token page
    assert_redirected_to expired_authentication_token_publishers_path(id: publisher.id)
    follow_redirect!

    # verify publisher is not redirected to homepage
    assert_response :success
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
      get(log_in_publishers_path)
      params = publisher.attributes.slice(*%w(brave_publisher_id email))
      put(registrations_path, params: params)
    end
  end

  def request_login_email_uppercase_email(publisher:)
    perform_enqueued_jobs do
      get(log_in_publishers_path)
      params = { email: publisher.email.upcase }
      put(registrations_path, params: params)
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

  test "relogin sends a login link email using case insensitive_email comparison" do
    publisher = publishers(:default)
    request_login_email_uppercase_email(publisher: publisher)
    email = ActionMailer::Base.deliveries.find do |message|
      message.to.first == publisher.email
    end

    assert_not_nil(email)
    url = publisher_url(publisher, token: publisher.reload.authentication_token)
    assert_email_body_matches(matcher: url, email: email)
  end

  # test "relogin for unverified publishers requires email" do
  #   publisher = publishers(:default)
  #   assert_enqueued_jobs(0) do
  #     get(log_in_publishers_path)
  #     params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id)) }
  #     post(create_authentication_token_publishers_path, params: params)
  #   end
  # end

  # test "relogin for unverified publishers fails with the wrong email" do
  #   publisher = publishers(:default)
  #   assert_enqueued_jobs(0) do
  #     get(log_in_publishers_path)
  #     params = { publisher: { "brave_publisher_id" => publisher.brave_publisher_id, "email" => "anon@cock.li" } }
  #     post(create_authentication_token_publishers_path, params: params)
  #   end
  # end

  # test "relogin for verified publishers without an email sends to the publisher's email" do
  #   publisher = publishers(:verified)
  #   perform_enqueued_jobs do
  #     get(log_in_publishers_path)
  #     params = { publisher: publisher.attributes.slice(*%w(brave_publisher_id)) }
  #     post(create_authentication_token_publishers_path, params: params)
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
      post(registrations_path, params: SIGNUP_PARAMS)
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
      post(registrations_path, params: SIGNUP_PARAMS)
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

  test "publisher completing signup will trigger RegisterPublisherWithSendGridJob" do
    perform_enqueued_jobs do
      post(registrations_path, params: SIGNUP_PARAMS)
    end

    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    assert_performed_with(job: RegisterPublisherWithSendGridJob) do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end
  end

  test "publisher updating contact email address will trigger RegisterPublisherWithSendGridJob" do
    perform_enqueued_jobs do
      post(registrations_path, params: SIGNUP_PARAMS)
    end

    publisher = Publisher.order(created_at: :asc).last
    url = publisher_url(publisher, token: publisher.authentication_token)
    get(url)
    follow_redirect!
    assert_performed_with(job: RegisterPublisherWithSendGridJob) do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

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
    assert_enqueued_with(job: RegisterPublisherWithSendGridJob) do
      get(url)
    end
    publisher.reload

    # verify email changes after confirmation
    assert_equal('alice-pending@example.com', publisher.email)

    # verify pending email is removed after confirmation
    assert_nil(publisher.pending_email)
  end
  test "after redirection back from uphold and uphold_api is online, a publisher's code is nil and uphold_access_parameters is set" do
    begin
      publisher = publishers(:completed)
      sign_in publisher

      uphold_code = 'ebb18043eb2e106fccb9d13d82bec119d8cd016c'
      uphold_state_token = SecureRandom.hex(64)
      publisher.uphold_connection.uphold_state_token = uphold_state_token

      publisher.save!

      stub_request(:post, "#{Rails.application.secrets[:uphold_api_uri]}/oauth2/token")
          .with(body: "code=#{uphold_code}&grant_type=authorization_code")
          .to_return(status: 201, body: "{\"access_token\":\"FAKEACCESSTOKEN\",\"token_type\":\"bearer\",\"refresh_token\":\"FAKEREFRESHTOKEN\",\"scope\":\"cards:write\"}")

      url = uphold_verified_publishers_path
      get(url, params: { code: uphold_code, state: uphold_state_token })
      assert(200, response.status)

      publisher.reload
      # verify that the uphold_state_token has been cleared
      assert_nil(publisher.uphold_connection.uphold_state_token)

      # verify that the uphold_code has been cleared
      assert_nil(publisher.uphold_connection.uphold_code)

      # verify that the uphold_access_parameters has been set
      assert_match('FAKEACCESSTOKEN', publisher.uphold_connection.uphold_access_parameters)

      assert_redirected_to '/publishers/home'
    end
  end

  test "when uphold fails to return uphold_access_parameters, publisher has option to reconnect with uphold" do
    # Turn off promo
    active_promo_id_original = Rails.application.secrets[:active_promo_id]
    Rails.application.secrets[:active_promo_id] = ""
    publisher = publishers(:completed)
    sign_in publisher

    # give pub uphold state token
    uphold_state_token = SecureRandom.hex(64)
    publisher.uphold_connection.uphold_state_token = uphold_state_token
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
    assert_equal publisher.uphold_connection.reload.uphold_status, :code_acquired

    # verify message tells publisher they need to reconnect
    assert_select("div#uphold_status.uphold-processing .status-description") do |element|
      assert_equal I18n.t("helpers.publisher.uphold_status_description.connecting"), element.text
    end

    # verify button says 'reconnect to uphold' not 'create uphold wallet'
    assert_select("[data-test=reconnect-button]") do |element|
      assert_equal I18n.t("helpers.publisher.uphold_authorization_description.reconnect_to_uphold"), element.text
    end
    Rails.application.secrets[:active_promo_id] = active_promo_id_original
  end

  test "a publisher's statement can be downloaded as html" do
    publisher = publishers(:uphold_connected)
    sign_in publisher

    get statement_publishers_path(publisher)
    assert_equal response.status, 200
    assert_equal response.header["Content-Type"], "application/html"
  end

  test "no statements are displayed if there are no transactions" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)
    sign_in publisher

    stub_all_eyeshade_wallet_responses(publisher: publisher)

    get statements_publishers_path(publisher)

    assert_match "content empty", response.body # This div displays the "No statements" message.
  end

  test "flashes 'no transactions' message when attempting to download a statement with no contents" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected)
    sign_in publisher

    stub_all_eyeshade_wallet_responses(publisher: publisher)

    get statement_publishers_path(publisher)

    assert_equal flash[:alert], I18n.t("publishers.statements.no_transactions")
  end

  test "a publisher's wallet can be polled via ajax" do
    publisher = publishers(:uphold_connected)
    sign_in publisher
    stub_request(:get, /me/).to_return(body: { currencies: [] }.to_json)

    get wallet_publishers_path, headers: { 'HTTP_ACCEPT' => "application/json" }

    assert_response 200

    wallet_response = JSON.parse(response.body)

    assert wallet_response["wallet"]["channel_balances"].present?
  end

  test "a publisher's uphold status can be polled via ajax" do
    publisher = publishers(:completed)
    sign_in publisher

    get uphold_status_publishers_path, headers: { 'HTTP_ACCEPT' => "application/json" }

    assert_response 200
    assert_equal '{"uphold_status":"unconnected",' +
                  '"uphold_status_summary":"Not connected",' +
                  '"uphold_status_description":"You need to connect to your Uphold account to receive contributions from Brave Rewards.",' +
                  '"uphold_status_class":"uphold-unconnected"}',
                 response.body
  end

  test "a publisher can be disconnected from uphold" do
    publisher = publishers(:uphold_connected_details)
    sign_in publisher

    patch disconnect_uphold_publishers_path, headers: { 'HTTP_ACCEPT' => "application/json" }

    assert_response 204

    publisher.reload
    refute publisher.uphold_connection.uphold_verified?
  end

  test "home redirects to 2FA prompt on first visit" do
    publisher = publishers(:unprompted)

    sign_in publisher
    get home_publishers_path

    assert_redirected_to prompt_security_publishers_path, "redirects on first visit"
    follow_redirect!

    get home_publishers_path
    assert_response :success
  end

  test "og meta tags should be set" do
    # ensure meta tags appear on static home apge
    get root_path
    ['og:image', 'og:title', 'og:description', 'og:url', 'og:type'].each do |meta_tag|
      assert_select "meta[property='#{meta_tag}']"
    end

    # ensure meta tags appear in publisher dashboard and elsewhere
    publisher = publishers(:completed)
    sign_in publisher
    get home_publishers_path

    ['og:image', 'og:title', 'og:description', 'og:url', 'og:type'].each do |meta_tag|
      assert_select "meta[property='#{meta_tag}']"
    end
  end

  test "completing signup adds, 'created', 'onboarding', 'active' status updates" do
    # Sign up fresh publisher
    url = nil
    publisher = nil

    perform_enqueued_jobs do
      post(registrations_path, params: SIGNUP_PARAMS)
      publisher = Publisher.find_by(pending_email: SIGNUP_PARAMS[:email])
      assert_equal "created", publisher.last_status_update.status

      ActionMailer::Base.deliveries.find do |message|
        message.to.first == SIGNUP_PARAMS[:email]
      end
      url = publisher_url(publisher, token: publisher.authentication_token)
    end
    get url
    publisher.reload
    # Verify email address
    assert_equal "onboarding", publisher.last_status_update.status

    # Agree to TOS
    perform_enqueued_jobs do
      patch(complete_signup_publishers_path, params: COMPLETE_SIGNUP_PARAMS)
    end

    publisher.reload
    assert publisher.agreed_to_tos.present?

    # Present two factor prompt
    follow_redirect!
    publisher.reload
    assert publisher.two_factor_prompted_at.present?

    assert publisher.last_status_update.status == "active"
  end

  test "publisher login activity is recorded" do
    publisher = publishers(:completed)
    login = publisher.last_login_activity
    assert_nil login

    sign_in publisher
    get home_publishers_path, headers: { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36",
                                         "HTTP_ACCEPT_LANGUAGE" => "en-US,en;q=0.9" }

    login = publisher.last_login_activity
    assert login
    assert_equal login.user_agent, "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"
    assert_equal login.accept_language, "en-US,en;q=0.9"
    assert login.browser.chrome?
  end

  test "#confirm_default_currency redirects publisher w/o cards:write to uphold if confirmed a not available currency" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    confirm_default_currency_params = {
      publisher: {
        default_currency: "BAT"
      }
    }

    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => false,
                             "possibleCurrencies" => ["BAT"],
                             "scope" => "cards:read, user:read" },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    patch(confirm_default_currency_publishers_path(publisher), params: confirm_default_currency_params)

    assert_response 200

    # assert_redirected_to uphold_authorization_endpoint(publisher)
    assert publisher.uphold_connection.default_currency_confirmed_at.present?
    assert publisher.uphold_connection.default_currency == "BAT"
  end

  test "#confirm_default_currency sets new default currency, initiates CreateUpholdCardsJob if not currency in available currency" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)

    sign_in publisher

    confirm_default_currency_params = {
      publisher: {
        default_currency: "BAT"
      }
    }

    # Mock the eyeshade wallet response to include cards:write scope
    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "possibleCurrencies" => ["BAT"],
                             "scope" => "cards:read, cards:write, user:read"},
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    patch(confirm_default_currency_publishers_path(publisher), params: confirm_default_currency_params)

    assert_response 200
    assert_equal(
      { action: 'refresh',
        status: 'Refreshing balances ...',
        timeout: 2000 }.to_json,
      response.body)

    assert publisher.uphold_connection.default_currency_confirmed_at.present?
    assert publisher.uphold_connection.default_currency == "BAT"
  end

  test "#confirm_default_currency creates BTC & BAT card, sets new default currency to BTC" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    confirm_default_currency_params = {
      publisher: {
        default_currency: "BTC"
      }
    }

    # Mock the eyeshade wallet response to include cards:write scope
    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => true,
                             "possibleCurrencies" => ["BAT", "BTC"],
                             "scope" => "cards:read, cards:write, user:read" },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    patch(confirm_default_currency_publishers_path(publisher), params: confirm_default_currency_params)

    assert_response 200
    assert_equal(
      { action: 'refresh',
        status: 'Refreshing balances ...',
        timeout: 2000 }.to_json,
      response.body)

    assert publisher.uphold_connection.default_currency_confirmed_at.present?
    assert publisher.uphold_connection.default_currency == "BTC"
  end

  test "#confirm_default_currency does not create new card after new publisher confirms available default currency" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    sign_in publisher

    confirm_default_currency_params = {
      publisher: {
        default_currency: "BAT"
      }
    }

    # Mock the eyeshade wallet response to include cards:write scope
    wallet = { "wallet" => { "defaultCurrency" => "BAT",
                             "authorized" => true,
                             "possibleCurrencies" => ["BAT"],
                             "scope" => "cards:read, cards:write, user:read" },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }
    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)\

    patch(confirm_default_currency_publishers_path(publisher), params: confirm_default_currency_params)

    assert_response 200
    assert_equal(
      { action: 'refresh',
        status: 'Refreshing balances ...',
        timeout: 2000 }.to_json,
      response.body)

    assert publisher.uphold_connection.default_currency_confirmed_at.present?
    assert publisher.uphold_connection.default_currency == "BAT"
  end

  test "after an existing publisher confirms default currency and gets cards:write scope, #home will create the cards" do
    Rails.application.secrets[:api_eyeshade_offline] = false
    publisher = publishers(:uphold_connected_currency_unconfirmed)
    stub_request(:get, /v0\/me/).to_return(body: { status: "ok", memberAt: "2019", uphold_id: "123e4567-e89b-12d3-a456-426655440000" }.to_json)

    sign_in publisher

    confirm_default_currency_params = {
      publisher: {
        default_currency: "BAT"
      }
    }

    wallet = { "wallet" => { "defaultCurrency" => "USD",
                             "authorized" => false,
                             "possibleCurrencies" => ["BAT"],
                             "scope" => "cards:read, user:read" },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    patch(confirm_default_currency_publishers_path(publisher), params: confirm_default_currency_params)

    assert_response 200

    assert publisher.uphold_connection.default_currency_confirmed_at.present?
    assert publisher.uphold_connection.default_currency == "BAT"

    wallet = { "wallet" => { "defaultCurrency" => "BAT",
                             "authorized" => true,
                             "possibleCurrencies" => ["BAT"],
                             "scope" => "cards:read, cards:write, user:read" },
               "rates" => {},
               "contributions" => { "currency" => "USD"}
    }

    stub_all_eyeshade_wallet_responses(publisher: publisher, wallet: wallet)

    get home_publishers_path
  end

  describe 'publisher integration with uphold' do
    let(:publisher) { publishers(:completed) }
    before(:example) do
      sign_in publisher

      # skip 2FA prompt
      publisher.two_factor_prompted_at = 1.day.ago
      publisher.save!
    end

    test "after redirection back from uphold and uphold_api is offline, a publisher's code is still set" do
      uphold_state_token = SecureRandom.hex(64)
      publisher.uphold_connection.uphold_state_token = uphold_state_token

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
      assert_nil(publisher.uphold_connection.uphold_state_token)

      # verify that the uphold_code has been set
      assert_not_nil(publisher.uphold_connection.uphold_code)
      assert_equal('ebb18043eb2e106fccb9d13d82bec119d8cd016c', publisher.uphold_connection.uphold_code)

      # verify that the uphold_access_parameters has not been set
      assert_nil(publisher.uphold_connection.uphold_access_parameters)

      # verify that the finished_header was not displayed
      refute_match(I18n.t('publishers.finished_header'), response.body)
    end
  end

end
