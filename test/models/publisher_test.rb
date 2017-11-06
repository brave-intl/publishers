require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class PublisherTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper

  test "uphold_code is only valid without uphold_access_parameters and before uphold_verified" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    assert publisher.valid?

    publisher.uphold_access_parameters = "bar"
    refute publisher.valid?
    assert_equal [:uphold_code], publisher.errors.keys

    publisher.uphold_access_parameters = nil
    publisher.uphold_verified = true
    refute publisher.valid?
    assert_equal [:uphold_code], publisher.errors.keys
  end

  test "uphold_access_parameters can not be set when uphold_verified" do
    publisher = publishers(:verified)
    publisher.uphold_code = nil
    publisher.uphold_access_parameters = nil
    publisher.uphold_verified = true
    assert publisher.valid?

    publisher.uphold_access_parameters = "bar"
    refute publisher.valid?
    assert_equal [:uphold_access_parameters], publisher.errors.keys
  end

  test "prepare_uphold_state_token generates a new uphold_state_token if one does not already exist" do
    publisher = publishers(:verified)
    publisher.uphold_state_token = nil
    publisher.prepare_uphold_state_token

    assert publisher.uphold_state_token
    assert publisher.valid?

    uphold_state_token = publisher.uphold_state_token
    publisher.prepare_uphold_state_token
    assert_equal uphold_state_token, publisher.uphold_state_token, 'uphold_state_token is not regenerated if it already exists'
  end

  test "receive_uphold_code sets uphold_code and clears other uphold fields" do
    publisher = publishers(:verified)
    publisher.uphold_state_token = "abc123"
    publisher.uphold_code = nil
    publisher.uphold_access_parameters = "bar"
    publisher.uphold_verified = false
    publisher.receive_uphold_code('secret!')

    assert_equal 'secret!', publisher.uphold_code
    assert_nil publisher.uphold_state_token
    assert_nil publisher.uphold_access_parameters
    assert publisher.valid?
    assert_equal :code_acquired, publisher.uphold_status
  end

  test "verify_uphold sets uphold_verified to true and clears uphold_code and uphold_access_parameters" do
    publisher = publishers(:verified)
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = "bar"
    publisher.uphold_verified = false
    publisher.verify_uphold

    assert publisher.uphold_verified?
    assert publisher.valid?
  end

  test "verify_uphold_status correctly calculated" do
    publisher = publishers(:verified)

    # unconnected
    publisher.uphold_code = nil
    publisher.uphold_access_parameters = nil
    publisher.uphold_verified = false
    assert publisher.valid?
    assert_equal :unconnected, publisher.uphold_status

    # code_acquired
    publisher.uphold_code = "foo"
    publisher.uphold_access_parameters = nil
    publisher.uphold_verified = false
    assert publisher.valid?
    assert_equal :code_acquired, publisher.uphold_status

    # access_parameters_acquired
    publisher.uphold_code = nil
    publisher.uphold_access_parameters = "bar"
    publisher.uphold_verified = false
    assert publisher.valid?
    assert_equal :access_parameters_acquired, publisher.uphold_status

    # verified
    publisher.uphold_code = nil
    publisher.uphold_access_parameters = nil
    publisher.uphold_verified = true
    assert publisher.valid?
    assert_equal :verified, publisher.uphold_status
  end

  test "when wallet is gotten the default currency will be initialized if not already set" do
    publisher = publishers(:verified)

    assert_nil publisher.default_currency
    publisher.wallet
    refute_nil publisher.default_currency
  end

  test "when wallet is gotten uphold_verified will be reset if the wallet status directs it" do
    prev_offline = Rails.application.secrets[:api_eyeshade_offline]
    begin
      Rails.application.secrets[:api_eyeshade_offline] = false
      
      body = "{ \"status\":{ \"provider\":\"uphold\", \"action\":\"re-authorize\" }, \"contributions\":{ \"amount\":\"9001.00\", \"currency\":\"USD\", \"altcurrency\":\"BAT\", \"probi\":\"38077497398351695427000\" }, \"rates\":{ \"BTC\":0.00005418424016883016, \"ETH\":0.000795331082073117, \"USD\":0.2363863335301452, \"EUR\":0.20187818378874756, \"GBP\":0.1799810085548496 }, \"wallet\":{ \"provider\":\"uphold\", \"authorized\":true, \"preferredCurrency\":\"USD\", \"availableCurrencies\":[ \"USD\", \"EUR\", \"BTC\", \"ETH\", \"BAT\" ] } }"

      stub_request(:get, /v2\/publishers\/uphold_connected.org\/wallet/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: body, headers: {})

      publisher = publishers(:uphold_connected)
      assert publisher.uphold_verified

      publisher.wallet
      refute publisher.uphold_verified

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end
end
