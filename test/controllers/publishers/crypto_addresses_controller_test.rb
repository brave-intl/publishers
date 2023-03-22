require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

module Publishers
  class CryptoAddressesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @publisher = publishers(:default)
      @crypto_address = crypto_addresses(:default_eth_address)
      sign_in @publisher
    end

    test "should get index" do
      get crypto_addresses_path, headers: {"HTTP_ACCEPT" => "application/json"}
      assert_response :success
      assert_equal true, assigns(:crypto_addresses).to_a.include?(@crypto_address)
    end

    test "should destroy crypto address" do
      delete crypto_address_path(@crypto_address), headers: {"HTTP_ACCEPT" => "application/json"}
      assert_response :no_content
      assert_nil CryptoAddress.find_by(id: @crypto_address.id)
    end

    test "should not destroy crypto address if not owned by the publisher" do
      CryptoAddressesController.any_instance.stubs(:current_publisher).returns(publishers(:verified))

      delete crypto_address_path(@crypto_address), headers: {"HTTP_ACCEPT" => "application/json"}

      assert_response :bad_request
      assert_not_nil CryptoAddress.find_by(id: @crypto_address.id)
    end
  end
end
