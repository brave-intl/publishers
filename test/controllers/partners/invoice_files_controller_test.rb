require "test_helper"
require "webmock/minitest"

class Partners::InvoicesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  describe '#create' do
    before do
      partner = partners(:default_partner)
      sign_in partner
      Invoice.destroy_all

      invoice = Invoice.create(partner: partner, date: "2019-01-01")
      file = fixture_file_upload(Rails.root.join('test','fixtures', '1x1.png'))

      post partners_payments_invoice_invoice_files_path(invoice_id: invoice.id),
        params: { file: file },
        headers: { 'content-type': 'multipart/form-data' }
    end

    it 'renders json' do
      assert JSON.parse(@response.body)["files"]
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

