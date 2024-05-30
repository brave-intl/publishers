require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class Api::Nextv1::CryptoAddressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @publisher = publishers(:default)
    @crypto_address = crypto_addresses(:default_eth_address)
    sign_in @publisher
  end

  test "should get index" do
    get "/api/nextv1/publishers/#{@publisher.id}/crypto_addresses", headers: {"HTTP_ACCEPT" => "application/json"}
    assert_response :success
    assert_equal true, assigns(:crypto_addresses).to_a.include?(@crypto_address)
  end

  test "should destroy crypto address" do
    delete "/api/nextv1/publishers/#{@publisher.id}/crypto_addresses/#{@crypto_address.id}", headers: {"HTTP_ACCEPT" => "application/json"}
    assert_response :ok
    assert_nil CryptoAddress.find_by(id: @crypto_address.id)
  end

  test "should not destroy crypto address if not owned by the publisher" do
    Api::Nextv1::CryptoAddressesController.any_instance.stubs(:current_publisher).returns(publishers(:verified))

    delete "/api/nextv1/publishers/#{@publisher.id}/crypto_addresses/#{@crypto_address.id}", headers: {"HTTP_ACCEPT" => "application/json"}

    assert_response :not_found
    assert_not_nil CryptoAddress.find_by(id: @crypto_address.id)
  end
end
