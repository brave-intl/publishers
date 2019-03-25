require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest

    describe '#sign_up' do
      describe 'when the email param is present' do
        it 'renders the page with a new publisher' do
        end
      end

      describe 'when the email param is missing' do
        it 'renders the page with a new publisher' do
        end
      end
    end

    describe '#log_in' do
      it 'renders the log_in page' do
      end

      it 'assigns @publishers' do
      end
    end

    describe '#create' do
      describe 'when the email already exists' do
      end

      describe 'when the email is not present' do
        it 'tells the user there was an error' do
        end
      end

      describe 'when the email is new' do
        it 'sends an email' do

        end

        it 'tells the user' do
        end
      end

      describe 'when the user it throttled' do
        it 'errors out' do
        end
      end
    end

    describe '#update' do
      describe 'when the email is not case sensitive' do
        it 'allows the user to still log in' do
        end
      end

      describe 'when the email is not present' do
        it 'shows the user an error' do
        end
      end

      describe 'when the user is throttled' do
      end

      describe 'when the user does not exist in the system' do
      end
    end

    describe '#expired_authentication_token' do


    end

    describe '#resend_authentication_email' do
      describe 'when the email is present' do
        it 'sends the email' do
        end
      end

      describe 'when the user is not present' do
        it 'does not send an email' do
        end
      end

      describe 'when the user is throttled' do
      end
    end

  end
end
