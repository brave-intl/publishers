require "test_helper"
require "webmock/minitest"

class Partners::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  describe "#show" do
    describe "when request is not authorized" do
      it 'does not suceed' do
        assert_raises RuntimeError do
          publisher = publishers(:default)
          sign_in publisher

          get partners_payments_path
        end
      end
    end

    describe "when request not authorized" do
      before do
        partner = publishers(:partner)
        sign_in partner
        get partners_payments_path
      end

      it 'succeeds' do
        assert_response :success
      end
    end
  end
end
