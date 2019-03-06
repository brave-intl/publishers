require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Admin::BlobsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  let(:file) { fixture_file_upload(Rails.root.join('test','fixtures', '1x1.png')) }
  let(:invoice_file) { @invoice_file ||= InvoiceFile.create(invoice: invoices(:default), file: file, uploaded_by: publishers(:completed_partner)) }
  let(:subject) {
    get rails_blob_url(invoice_file.file, disposition: "attachment")
  }

  before do
    InvoiceFile.destroy_all
  end

  describe 'when user is authenticated' do
    describe 'and the user is an admin' do
      before do
        admin = publishers(:admin)
        sign_in admin

        subject
      end

      it 'redirects to the file' do
        assert_match /.png/, @response.redirect_url
      end

      it 'has no flash' do
        refute flash[:alert]
      end
    end

    describe 'and the user is not authorized' do
      before do
        publisher = publishers(:default)
        sign_in publisher
        subject
      end

      it 'flashes an unauthorized message' do
        assert_equal flash[:alert], I18n.t('devise.failure.unauthorized')
      end
    end

    describe 'and the user is authorized' do
      before do
        partner = publishers(:completed_partner)
        sign_in partner
        subject
      end

      it 'redirects to the file' do
        assert_match /.png/, @response.redirect_url
      end

      it 'has no flash' do
        refute flash[:alert]
      end
    end
  end

  describe 'when the user is not authenticated' do
    before { subject }

    it 'redirects and flashes a message' do
      assert_equal flash[:alert], I18n.t('devise.failure.unauthenticated')
    end
  end
end
