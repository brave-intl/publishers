require "test_helper"
require "webmock/minitest"

class Partners::InvoicesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  describe "#index" do
    describe "when request is not authorized" do
      it 'does not suceed' do
        assert_raises RuntimeError do
          publisher = publishers(:default)
          sign_in publisher

          get partners_payments_invoices_path
        end
      end
    end

    describe "when request is html" do
      before do
        partner = publishers(:partner)
        sign_in partner

        get partners_payments_invoices_path
      end

      it 'renders the html' do
        assert_template :index
      end

      it 'assigns @invoices' do
        assert controller.instance_variable_get("@invoices") 
      end
    end

    describe "when request is JSON" do
      before do
        partner = publishers(:partner)
        sign_in partner

        get partners_payments_invoices_path, as: :json
      end

      it 'renders json' do
        assert JSON.parse(@response.body)
      end

      it 'assigns @invoices' do
        assert controller.instance_variable_get("@invoices") 
      end
    end
  end

  describe '#create' do
    before do
      Invoice.destroy_all

      partner = publishers(:partner)
      sign_in partner

      file = fixture_file_upload(Rails.root.join('test','fixtures', '1x1.png'))

      post partners_payments_invoices_path, 
        params: { file: file },
        headers: { 'content-type': 'multipart/form-data' }
    end

    it 'creates an invoice' do
      assert Invoice.first
    end

    it 'creates with an attachment' do
      assert Invoice.first.file
    end
  end
end
