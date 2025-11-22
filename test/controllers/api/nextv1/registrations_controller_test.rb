# typed: false
# frozen_string_literal: true

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"
require "test_helpers/csrf_getter"

class Api::Nextv1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include Devise::Test::IntegrationHelpers
  include CsrfGetter
  include MockRewardsResponses

  before do
    ActionMailer::Base.deliveries.clear
    stub_rewards_parameters
    @csrf_token = get_csrf_token
  end

  describe "#create" do
    let(:create_email) { "alice@verified.org" }
    let(:subject) {
      post(api_nextv1_registrations_path,
        params: {email: create_email, terms_of_service: true},
        headers: {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => @csrf_token})
    }

    describe "when the email already exists" do
      it "sends an email" do
        assert_enqueued_emails(1) { subject }
      end
    end

    describe "when the email is not present" do
      let(:create_email) { nil }

      before do
        subject
      end

      it "tells the user there was an error" do
        assert_equal(400, response.status)
      end
    end

    describe "when the email is new" do
      let(:create_email) { "brand_new@example.com" }

      it "sends a verification email" do
        # Internal and verify link
        perform_enqueued_jobs { subject }
        email = ActionMailer::Base.deliveries.find { |m| m.to.first == create_email }
        assert email.subject, I18n.t("publisher_mailer.verify_email.subject")
      end
    end
  end

  describe "#update" do
    let(:update_email) { "ALiCE@Verified.org" }
    let(:subject) { patch(api_nextv1_registrations_path, params: {email: update_email}, headers: {"HTTP_ACCEPT" => "application/json", "X-CSRF-Token" => @csrf_token}) }

    describe "when the email is not case sensitive" do
      it "allows the user to still log in" do
        assert_enqueued_emails(1) { subject }
      end
    end
  end
end
