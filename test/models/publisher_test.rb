require "test_helper"
require "shared/mailer_test_helper"
require "webmock/minitest"

class PublisherTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include MailerTestHelper
  include PromosHelper

  test "verified publishers have both a name and email and have agreed to the TOS" do
    publisher = Publisher.new
    refute publisher.email_verified?
    refute publisher.verified?

    publisher.email = "jane@example.com"
    assert publisher.email_verified?
    refute publisher.verified?

    publisher.name = "Jane"
    refute publisher.verified?

    publisher.agreed_to_tos = 1.minute.ago
    assert publisher.verified?
  end

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

      publisher = publishers(:uphold_connected)
      assert publisher.uphold_verified

      stub_request(:get, /v1\/owners\/#{URI.escape(publisher.owner_identifier)}\/wallet/).
          with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
          to_return(status: 200, body: body, headers: {})

      publisher.channels.each do |channel|
        body = "{ \"amount\":\"9001.00\", \"currency\":\"USD\", \"altcurrency\":\"BAT\", \"probi\":\"38077497398351695427000\", \"rates\":{ \"BTC\":0.00005418424016883016, \"ETH\":0.000795331082073117, \"USD\":0.2363863335301452, \"EUR\":0.20187818378874756, \"GBP\":0.1799810085548496 } }"
        stub_request(:get, /v2\/publishers\/#{URI.escape(channel.details.channel_identifier)}\/balance/).
            with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
            to_return(status: 200, body: body, headers: {})
      end

      publisher.wallet
      refute publisher.uphold_verified

    ensure
      Rails.application.secrets[:api_eyeshade_offline] = prev_offline
    end
  end

  test "a publisher must have a valid pending email address if it does not have an email address" do
    publisher = Publisher.new

    assert_nil publisher.email
    assert_nil publisher.pending_email
    refute publisher.valid?

    publisher.pending_email = "foo@bar.com"
    assert publisher.valid?

    publisher.email = "foo@bar.com"
    publisher.pending_email = nil
    assert publisher.valid?

    publisher.email = "foo@bar.com"
    publisher.pending_email = "bar@bar.com"
    assert publisher.valid?
  end

  test "a publisher pending_email address must be valid" do
    publisher = Publisher.new

    publisher.pending_email = "bad_email_addresscom"
    refute publisher.valid?
  end

  test "a publisher pending_email address must not match an existing verified email address" do
    publisher = Publisher.new

    publisher.pending_email = "foo@bar.com"
    assert publisher.valid?

    publisher.pending_email = "alice@verified.org"
    refute publisher.valid?
  end

  test "a publisher pending_email address must not match the verified email address" do
    publisher = Publisher.new

    publisher.email = "foo@bar.com"
    assert publisher.valid?

    publisher.pending_email = "foo@bar.com"
    refute publisher.valid?
  end

  test "a publisher can be destroyed if it is not verified" do
    publisher = Publisher.new

    publisher.pending_email = "foo@foo.com"
    assert publisher.valid?
    publisher.save
    assert_difference("Publisher.count", -1) do
      assert publisher.destroy
    end
  end

  test "a publisher can not be destroyed if it has channels" do
    publisher = publishers(:verified)
    assert_difference("Publisher.count", 0) do
      refute publisher.destroy
    end
  end

  test "test `has_stale_uphold_code` scopes to correct publishers" do
    publisher = publishers(:default)
    
    # verify there are no publishers with stale codes to begin with
    assert_equal Publisher.has_stale_uphold_code.count, 0

    # verify scope includes publisher if uphold_code exist and exceeds timeout
    publisher.uphold_code = "foo"
    publisher.save
    publisher.uphold_updated_at = Publisher::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.save
    assert_equal Publisher.has_stale_uphold_code.count, 1

    # verify scope does not include publisher if uphold_code exists and within timeout
    publisher.uphold_code = "bar"
    publisher.save    
    assert_equal Publisher.has_stale_uphold_code.count, 0

    # verify scope does not include publisher if uphold_code does not exist and within timeout
    publisher.uphold_code = nil
    publisher.save
    assert_equal Publisher.has_stale_uphold_code.count, 0

    # verify scope does not include publisher if uphold_code does not exist and exceeds timeout
    publisher.uphold_code = nil
    publisher.save!
    publisher.uphold_updated_at = Publisher::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.save!
    assert_equal Publisher.has_stale_uphold_code.count, 0
  end

  test "test `has_stale_access_params` scopes to correct publishers " do
    publisher = publishers(:default)
    
    # verify there are no publishers with stale codes to begin with
    assert_equal Publisher.has_stale_uphold_access_parameters.count, 0

    # verify scope includes publisher if uphold_access_params exist and exceeds timeout
    publisher.uphold_access_parameters = "foo"
    publisher.save
    publisher.uphold_updated_at = Publisher::UPHOLD_ACCESS_PARAMS_TIMEOUT.ago - 1.minute
    publisher.save
    assert_equal Publisher.has_stale_uphold_access_parameters.count, 1

    # verify scope does not include publisher if uphold_access_params exists and within timeout
    publisher.uphold_access_parameters = "bar"
    publisher.save    
    assert_equal Publisher.has_stale_uphold_access_parameters.count, 0

    # verify scope does not include publisher if uphold_access_params does not exist and within timeout
    publisher.uphold_access_parameters = nil
    publisher.save
    assert_equal Publisher.has_stale_uphold_access_parameters.count, 0

    # verify scope does not include publisher if uphold_access_params does not exist and exceeds timeout
    publisher.uphold_access_parameters = nil
    publisher.save!
    publisher.uphold_updated_at = Publisher::UPHOLD_CODE_TIMEOUT.ago - 1.minute
    publisher.save!
    assert_equal Publisher.has_stale_uphold_access_parameters.count, 0
  end

  test "test `before_validation :set_uphold_updated_at` updates correctly" do
    publisher = publishers(:default)

    # verify uphold_updated_at has been set after `uphold_state_token` updated
    publisher.uphold_updated_at = 1.hour.ago
    publisher.save
    publisher.uphold_state_token = "foo"
    publisher.save
    assert publisher.uphold_updated_at > 30.minutes.ago

    # verify uphold_updated_at has been set after `uphold_code` updated
    publisher.uphold_updated_at = 1.hour.ago
    publisher.save
    publisher.uphold_code = "foo"
    publisher.save
    assert publisher.uphold_updated_at > 30.minutes.ago

    # verify uphold_updated_at has been set after `uphold_access_parameters` updated
    publisher.uphold_updated_at = 1.hour.ago
    publisher.uphold_code = nil
    publisher.save
    publisher.uphold_access_parameters = "foo"
    publisher.save
    assert publisher.uphold_updated_at > 30.minutes.ago
  end

  test "formats owner_identifier correctly" do
    publisher = publishers(:default)

    assert_equal "publishers#uuid:02e81b29-f150-54b9-9a08-ce75944f6889", publisher.owner_identifier
  end
end
