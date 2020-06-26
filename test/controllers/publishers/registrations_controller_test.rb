# frozen_string_literal: true

require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    include ActionMailer::TestHelper
    include Devise::Test::IntegrationHelpers

    before do
      ActionMailer::Base.deliveries.clear
    end

    describe '#sign_up' do
      let(:email) { }
      let(:subject) { get sign_up_publishers_path(email: email) }

      before do
        subject
      end

      describe 'when the email param is present' do
        let(:email) { 'user@example.com' }

        it 'renders the page' do
          assert_response :success
        end

        it 'assigns @publisher' do
          assert controller.instance_variable_get("@publisher")
        end
      end

      describe 'when the email param is missing' do
        it 'renders the page' do
          assert_response :success
        end

        it 'assigns @publisher' do
          assert controller.instance_variable_get("@publisher")
        end
      end
    end

    describe '#log_in' do
      before do
        get log_in_publishers_path
      end

      it 'renders the log_in page' do
        assert_response :success
      end

      it 'assigns @publishers' do
        assert controller.instance_variable_get("@publisher")
      end
    end

    describe '#create' do
      let(:create_email) { 'alice@verified.org' }
      let(:subject) { post(registrations_path, params: { email: create_email, terms_of_service: true }) }

      describe 'when the email already exists' do
        it 'sends an email' do
          assert_enqueued_emails(1) { subject }
        end

        it 'alerts the user' do
          subject
          assert_equal flash[:notice], I18n.t("publishers.registrations.create.email_already_active", email: create_email)
        end
      end

      describe 'when the email is not present' do
        let(:create_email) { nil }

        before do
          subject
        end

        it 'tells the user there was an error' do
          assert_equal flash[:warning], I18n.t("publishers.registrations.create.invalid_email")
        end

        it 'redirects back to the sign up page' do
          assert_redirected_to controller: '/publishers/registrations', action: 'sign_up'
        end
      end

      describe 'when the email is new' do
        let(:create_email) { 'brand_new@example.com' }

        it 'sends a verification email' do
          # Internal and verify link
          perform_enqueued_jobs { subject }
          email = ActionMailer::Base.deliveries.find { |m| m.to.first == create_email }
          assert email.subject, I18n.t('publisher_mailer.verify_email.subject')
        end

        it 'renders the emailed_authentication_token view' do
          subject
          assert_template :emailed_authentication_token
        end

        it 'has no flash' do
          subject
          assert_nil flash[:notice]
        end
      end
    end

    describe '#update' do
      let(:update_email) { 'ALiCE@Verified.org' }
      let(:subject) { patch(registrations_path, params: { email: update_email }) }

      describe 'when the email is not case sensitive' do
        it 'allows the user to still log in' do
          assert_enqueued_emails(1) { subject }
        end
      end
    end

    describe '#expired_authentication_token' do
      let(:id) { publishers(:default).id }
      let(:subject) { post(resend_authentication_email_publishers_path, params: { id: id }) }

      before do
        subject
      end

      it 'renders properly' do
        assert_response :success
      end
    end

    describe '#resend_authentication_email' do
      let(:id) { publishers(:default).id }
      let(:subject) { post(resend_authentication_email_publishers_path, params: { id: id }) }

      describe 'when the email is present' do
        it 'sends the email' do
          assert_enqueued_emails(1) { subject }
        end
      end

      describe 'when the user is not present' do
        let(:id) { nil }

        it 'raises a not found error' do
          assert_raises(ActiveRecord::RecordNotFound) { subject }
        end
      end
    end
  end
end
