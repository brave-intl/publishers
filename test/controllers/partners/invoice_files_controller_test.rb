require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Partners::InvoicesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  describe '#create' do
    let(:invoice) { Invoice.create(partner: partner, date: "2019-01-01") }
    let(:partner) { partners(:default_partner) }
    let(:file) { fixture_file_upload(Rails.root.join('test','fixtures', '1x1.png')) }

    before do
      Rails.application.secrets[:bizdev_email] = 'noreply@brave.com'

      sign_in partner
      Invoice.destroy_all

      post partners_payments_invoice_invoice_files_path(invoice_id: invoice.id),
        params: { file: file },
        headers: { 'content-type': 'multipart/form-data' }
    end

    it 'renders json' do
      assert JSON.parse(@response.body)["files"]
    end

    it 'sends an email' do
      assert_enqueued_emails(1) do
        post partners_payments_invoice_invoice_files_path(invoice_id: invoice.id),
          params: { file: file },
          headers: { 'content-type': 'multipart/form-data' }
      end
    end
  end


  describe '#destroy' do
    before do
      partner = partners(:default_partner)
      sign_in partner
      Invoice.destroy_all
      InvoiceFile.destroy_all

      invoice = Invoice.create(partner: partner, date: "2019-01-01")
      file = InvoiceFile.create(invoice: invoice)

      delete partners_payments_invoice_invoice_file_path(id: file.id, invoice_id: '_')
    end

    it 'renders json' do
      assert_empty JSON.parse(@response.body)["files"]
    end
  end

  describe 'when user is not authenticated' do
    it 'raises an error' do
      assert_raises RuntimeError do
        delete partners_payments_invoice_invoice_file_path(id: 'id', invoice_id: '_')
      end
    end
  end
end

