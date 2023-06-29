require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class CryptoAddressForChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Eth

  setup do
    @channel = channels(:verified)
    @crypto_address = crypto_addresses(:eth_address)
    @publisher = publishers(:verified)
    @controller = CryptoAddressForChannelsController.new
    sign_in @publisher
  end

  test "should get index" do
    get channel_crypto_address_for_channels_path(@channel), headers: {"HTTP_ACCEPT" => "application/json"}
    assert_response :success
    assert_equal @crypto_address.crypto_address_for_channels.first, assigns(:crypto_addresses_for_channel).find(@crypto_address.id)
  end

  test "should create crypto address for channel" do
    signature = "49gfaNA9d9KkabVNB48VsSNrJLh8AnRvWYTBJ7ws9wRhZvvuyGivqg56kpSZtrvNCsdVzFxEgPGnc7KS5WSyM3FF"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    chain = "SOL"
    message = "6tp6l5LIOkUcC0w27isXCBDQoOl5m7ki"
    Rails.cache.write(message, true)

    CryptoAddressForChannelsController.any_instance.expects(:verify_solana_address).with(signature, account_address, message).returns(true)
    CryptoAddressForChannelsController.any_instance.expects(:replace_crypto_address_for_channel).with(account_address, chain, @channel).returns(true)

    post channel_crypto_address_for_channels_path(@channel), params: {
      transaction_signature: signature,
      account_address: account_address,
      chain: chain,
      message: message
    }, headers: {"HTTP_ACCEPT" => "application/json"}

    assert_response :created
  end

  test "should return error when creating crypto address for channel with invalid verification" do
    signature = "3mAsCPAU88U3U4AplCrrPMuL8K3df3ydGoqaQRSXqgqzM2o1zpzsk2JU9uY8Z1oke7nSgCc1Lhaxu7K5sowt6Z6p"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    chain = "SOL"
    message = "this is an arbitrary string"

    post channel_crypto_address_for_channels_path(@channel), params: {
      transaction_signature: signature,
      account_address: account_address,
      chain: chain,
      message: message
    }, headers: {"HTTP_ACCEPT" => "application/json"}

    assert_response :bad_request
    assert_equal ["message is invalid"], JSON.parse(response.body)["errors"]
  end

  test "should change address for channel" do
    account_address = "0xbB3Ea1e03A2dC8Bd2777D5Ea886a55e3573E726e"
    chain = "ETH"

    CryptoAddressForChannelsController.any_instance.expects(:replace_crypto_address_for_channel).with(account_address, chain, @channel).returns(true)

    post change_address_channel_crypto_address_for_channels_path(@channel), params: {
      address: account_address,
      chain: chain
    }, headers: {"HTTP_ACCEPT" => "application/json"}

    assert_response :success
  end

  test "should return error when changing address for channel with invalid parameters" do
    account_address = nil
    chain = "ETH"
    post change_address_channel_crypto_address_for_channels_path(@channel), params: {
      address: account_address,
      chain: chain
    }, headers: {"HTTP_ACCEPT" => "application/json"}

    assert_response :bad_request
    assert_equal "address could not be updated", JSON.parse(response.body)["errors"]
  end

  test "should verify Solana address" do
    signature = "49gfaNA9d9KkabVNB48VsSNrJLh8AnRvWYTBJ7ws9wRhZvvuyGivqg56kpSZtrvNCsdVzFxEgPGnc7KS5WSyM3FF"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    message = "6tp6l5LIOkUcC0w27isXCBDQoOl5m7ki"

    assert_equal true, @controller.verify_solana_address(signature, account_address, message)
  end

  test "should verify Ethereum address" do
    signature = "0xc6ed3f93f3ca79fc3ebd7548d4adb79ef70a5fbea35ed088ffe265389be4f65f4980e056316bedb515ffafe1dda3889f7e753c78d26dd16146e39ee7e62382021b"
    address = "0x3430E11a53fE270C0ce3997AfFf1Ba6F9B48b59F"
    message = "1686284137397"

    Eth::Signature.expects(:personal_recover).with(message, signature).returns(address)
    Eth::Util.expects(:public_key_to_address).with(address).returns(Eth::Address.new(address))

    assert_equal true, @controller.verify_ethereum_address(signature, address, message)
  end
end
