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

  describe '#update' do
    let(:date) { "2019-1" }
    let(:partner) { publishers(:partner) }
    let(:amount) { "30" }

    before do
      Invoice.destroy_all

      sign_in partner

      invoice = Invoice.create(
        date: DateTime.parse('January 2019').utc,
        partner: partner.becomes(Partner),
        amount: "10"
      )

      patch partners_payments_invoice_path(partner: partner, id: date), params: { amount: amount }
    end

    it 'updates the amount' do
      assert JSON.parse(@response.body)["amount"], amount
    end

    it 'renders json' do
      assert JSON.parse(@response.body)
    end

  end
end
