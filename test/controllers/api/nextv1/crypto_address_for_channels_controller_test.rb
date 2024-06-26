require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"
require "eth"
require 'test_helpers/csrf_getter'

class Api::Nextv1::CryptoAddressForChannelsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CsrfGetter

  setup do
    @channel = channels(:verified)
    @crypto_address = crypto_addresses(:eth_address)
    @publisher = publishers(:verified)
    sign_in @publisher
  end

  before do
    ActionController::Base.allow_forgery_protection = true
    @csrf_token = get_csrf_token
    ActionController::Base.allow_forgery_protection = false
  end

  test "should get index" do
    ActionController::Base.allow_forgery_protection = true

    get "/api/nextv1/channels/#{@channel.id}/crypto_address_for_channels", headers: {"HTTP_ACCEPT" => "application/json", 'X-CSRF-Token' => @csrf_token}
    assert_response :success
    assert_equal @crypto_address.crypto_address_for_channels.first, assigns(:crypto_addresses_for_channel).find(@crypto_address.id)
    ActionController::Base.allow_forgery_protection = false
  end

  test "should create crypto address for channel" do
    ActionController::Base.allow_forgery_protection = true

    signature = "agABpynouN8NTjAxZXk5fEpfKRRiQ1nfc813juxr8a71TRsXxetiKeLahSbJC8XJTyz684PKtXq28snBoSTPB2s"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    chain = "SOL"
    message = "d1133a45-deed-4398-9f85-5df3864ca460"
    Rails.cache.write(message, @publisher.id)

    Util::CryptoUtils.expects(:verify_solana_address).with(signature, account_address, message, @publisher).returns(true)
    Api::Nextv1::CryptoAddressForChannelsController.any_instance.expects(:replace_crypto_address_for_channel).with(account_address, chain, @channel).returns(true)

    post "/api/nextv1/channels/#{@channel.id}/crypto_address_for_channels", params: {
      transaction_signature: signature,
      account_address: account_address,
      chain: chain,
      message: message
    }, headers: {"HTTP_ACCEPT" => "application/json", 'X-CSRF-Token' => @csrf_token}

    assert_response :created

    ActionController::Base.allow_forgery_protection = false
  end

  test "should return error when creating crypto address for channel with invalid verification" do
    ActionController::Base.allow_forgery_protection = true

    signature = "3mAsCPAU88U3U4AplCrrPMuL8K3df3ydGoqaQRSXqgqzM2o1zpzsk2JU9uY8Z1oke7nSgCc1Lhaxu7K5sowt6Z6p"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    chain = "SOL"
    message = "this is an arbitrary string"

    post "/api/nextv1/channels/#{@channel.id}/crypto_address_for_channels", params: {
      transaction_signature: signature,
      account_address: account_address,
      chain: chain,
      message: message
    }, headers: {"HTTP_ACCEPT" => "application/json", 'X-CSRF-Token' => @csrf_token}

    assert_response :bad_request
    assert_equal ["message is invalid"], JSON.parse(response.body)["errors"]

    ActionController::Base.allow_forgery_protection = false
  end

  test "should change address for channel" do
    ActionController::Base.allow_forgery_protection = true
    account_address = "0xbB3Ea1e03A2dC8Bd2777D5Ea886a55e3573E726e"
    chain = "ETH"

    Api::Nextv1::CryptoAddressForChannelsController.any_instance.expects(:replace_crypto_address_for_channel).with(account_address, chain, @channel).returns(true)

    post "/api/nextv1/channels/#{@channel.id}/crypto_address_for_channels/change_address", params: {
      address: account_address,
      chain: chain
    }, headers: {"HTTP_ACCEPT" => "application/json", 'X-CSRF-Token' => @csrf_token}

    assert_response :success
    ActionController::Base.allow_forgery_protection = false
  end

  test "should return error when changing address for channel with invalid parameters" do
    ActionController::Base.allow_forgery_protection = true
    account_address = nil
    chain = "ETH"
    post "/api/nextv1/channels/#{@channel.id}/crypto_address_for_channels/change_address", params: {
      address: account_address,
      chain: chain
    }, headers: {"HTTP_ACCEPT" => "application/json", 'X-CSRF-Token' => @csrf_token}

    assert_response :bad_request
    assert_equal "address could not be updated", JSON.parse(response.body)["errors"]
    ActionController::Base.allow_forgery_protection = false
  end

  test "should verify Solana address" do
    ActionController::Base.allow_forgery_protection = true
    signature = "agABpynouN8NTjAxZXk5fEpfKRRiQ1nfc813juxr8a71TRsXxetiKeLahSbJC8XJTyz684PKtXq28snBoSTPB2s"
    account_address = "36fsf2BR6KNpHPLo9VawfoWEBqncKRMUpxbi3JVBNFWA"
    message = "d1133a45-deed-4398-9f85-5df3864ca460"

    assert_equal true, Util::CryptoUtils.verify_solana_address(signature, account_address, message, @publisher)
    ActionController::Base.allow_forgery_protection = false
  end

  test "should verify Ethereum address" do
    ActionController::Base.allow_forgery_protection = true
    signature = "0xc6ed3f93f3ca79fc3ebd7548d4adb79ef70a5fbea35ed088ffe265389be4f65f4980e056316bedb515ffafe1dda3889f7e753c78d26dd16146e39ee7e62382021b"
    address = "0x3430E11a53fE270C0ce3997AfFf1Ba6F9B48b59F"
    message = "1686284137397"

    Eth::Signature.expects(:personal_recover).with(message, signature).returns(address)
    Eth::Util.expects(:public_key_to_address).with(address).returns(Eth::Address.new(address))

    assert_equal true, Util::CryptoUtils.verify_ethereum_address(signature, address, message, @publisher)
    ActionController::Base.allow_forgery_protection = false
  end
end
