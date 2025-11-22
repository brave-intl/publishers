# typed: false
# frozen_string_literal: true

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    include ActionMailer::TestHelper
    include Devise::Test::IntegrationHelpers
    include MockRewardsResponses

    before do
      ActionMailer::Base.deliveries.clear
      stub_rewards_parameters
    end

    describe "#expired_authentication_token" do
      let(:id) { publishers(:default).id }

      it "renders properly" do
        get(expired_authentication_token_publishers_path, params: {id: id})
        assert_response :success
      end

      it "redirects on bad user" do
        get(expired_authentication_token_publishers_path, params: {id: "blahblahblacksheep"})
        assert_redirected_to root_path + "?locale=en"
      end
    end

    describe "#resend_authentication_email" do
      let(:id) { publishers(:default).id }
      let(:subject) { post(resend_authentication_email_publishers_path, params: {id: id}) }

      describe "when the email is present" do
        it "sends the email" do
          assert_enqueued_emails(1) { subject }
        end
      end

      describe "when the user is not present" do
        let(:id) { nil }

        it "raises a not found error" do
          assert_raises(ActiveRecord::RecordNotFound) { subject }
        end
      end
    end
  end
end
