# typed: false

require "test_helper"
require "eyeshade/wallet"

class PublishersHelperTest < ActionView::TestCase
  let(:rates) do
    {
      payload: {
        bat: {
          btc: 0.00001002,
          btc_timeframe_change: 0,
          eth: 0.00013862,
          eth_timeframe_change: 0,
          eur: 0.15505,
          eur_timeframe_change: 0,
          gbp: 0.137403,
          gbp_timeframe_change: 0,
          usd: 0.165864,
          usd_timeframe_change: 0.69631645135915
        }
      },
      lastUpdated: "2022-12-30T19:24:23.405184202Z"
    }
  end

  test "publisher_channel_bat_balance should return 0 when tiny balance" do
    channel_identifier = "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b"
    balance = "0.0000000009"
    accounts = [
      {
        "account_id" => channel_identifier,
        "account_type" => "channel",
        "balance" => balance
      }
    ]
    transactions = []
    fake_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "BAT")
    publisher = mock
    publisher.expects(:wallet).returns(fake_wallet).at_least_once

    output = publisher_channel_bat_balance(publisher, channel_identifier)
    # TODO: Not familiar with the %{} syntax.
    assert_dom_equal("0.00", output)
  end

  test "publisher_channel_bat_balance should return 0 when negative balance" do
    channel_identifier = "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b"
    balance = "-0.111"
    accounts = [
      {
        "account_id" => channel_identifier,
        "account_type" => "channel",
        "balance" => balance
      }
    ]
    transactions = []
    fake_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "BAT")
    publisher = mock
    publisher.expects(:wallet).returns(fake_wallet).at_least_once

    output = publisher_channel_bat_balance(publisher, channel_identifier)
    # TODO: Not familiar with the %{} syntax.
    assert_dom_equal("0.00", output)
  end

  test "publisher_converted_overall_balance should return nothing for unset publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = nil
    publisher.save
    assert_dom_equal %(), publisher_converted_overall_balance(publisher)
  end

  test "publisher_converted_overall_balance should return nothing for BAT publisher currency" do
    publisher = publishers(:default)
    assert_dom_equal %(), publisher_converted_overall_balance(publisher)
  end

  test "publisher_converted_overall_balance should return something for set publisher currency" do
    publisher = publishers(:uphold_connected_details)
    publisher.save

    assert_dom_equal %(~ 188.14 USD), publisher_converted_overall_balance(publisher) # 0 balance because this publisher has no channels
  end

  class FakePublisher
    attr_reader :default_currency, :wallet, :uphold_connection

    def initialize(rates: {}, accounts: [], transactions: [], uphold_connection: nil)
      @uphold_connection = UpholdConnection.new(uphold_connection)
      @wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: @uphold_connection.default_currency)
    end

    def partner?
      false
    end

    def only_user_funds?
      false
    end

    def no_grants?
      false
    end

    def selected_wallet_provider
      @uphold_connection
    end
  end

  test "publisher_converted_overall_balance should return `CURRENCY unavailable` when no wallet is set" do
    publisher = publishers(:uphold_connected_details)

    assert_not_nil publisher.wallet
    assert_dom_equal %(~ 188.14 USD), publisher_converted_overall_balance(publisher)
  end

  test "can extract the uuid from an owner_identifier" do
    assert_equal "b8317d8a-78a4-48a6-9eeb-a2674c6455c4", publisher_id_from_owner_identifier("publishers#uuid:b8317d8a-78a4-48a6-9eeb-a2674c6455c4")
  end

  test "publishers_last_settlement_balance should return at least a positive 0 value" do
    publisher = FakePublisher.new(
      uphold_connection: {
        default_currency: "BAT"
      },
      rates: {
        payload: {
          bat: {
            btc: 0.00001002,
            btc_timeframe_change: 0,
            eth: 0.00013862,
            eth_timeframe_change: 0,
            eur: 0.15505,
            eur_timeframe_change: 0,
            gbp: 0.137403,
            gbp_timeframe_change: 0,
            usd: 0.165864,
            usd_timeframe_change: 0.69631645135915
          }
        },
        lastUpdated: "2022-12-30T19:24:23.405184202Z"
      },
      accounts: [
        {
          "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "account_type" => "owner",
          "balance" => "-58.217204799751874334"
        }
      ],
      transactions: [
        {
          "created_at" => "2018-11-07 00:00:00 -0800",
          "description" => "payout for referrals",
          "channel" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "amount" => "-94.617182149806375904",
          "settlement_currency" => "BAT",
          "settlement_amount" => "18.81",
          "type" => "referral_settlement"
        }
      ]
    )
    assert_not_nil publisher.wallet
    assert_equal "~ 0.00 BAT", publisher_converted_overall_balance(publisher)
    assert_equal "0.00", publisher_overall_bat_balance(publisher)
  end

  test "publishers_last_settlement_balance should return a formatted & converted wallet balance, last settlement balances do not apply fee" do
    publisher = FakePublisher.new(
      uphold_connection: {
        default_currency: "USD"
      },
      rates: {
        payload: {
          bat: {
            btc: 0.00001002,
            btc_timeframe_change: 0,
            eth: 0.00013862,
            eth_timeframe_change: 0,
            eur: 0.15505,
            eur_timeframe_change: 0,
            gbp: 0.137403,
            gbp_timeframe_change: 0,
            usd: 0.165864,
            usd_timeframe_change: 0.69631645135915
          }
        },
        lastUpdated: "2022-12-30T19:24:23.405184202Z"
      },
      accounts: [
        {
          "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "account_type" => "owner",
          "balance" => "58.217204799751874334"
        }
      ],
      transactions: [
        {
          "created_at" => "2018-11-07 00:00:00 -0800",
          "description" => "payout for referrals",
          "channel" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "amount" => "-94.617182149806375904",
          "settlement_currency" => "USD",
          "settlement_amount" => "18.81",
          "type" => "referral_settlement"
        }
      ]
    )
    assert_not_nil publisher.wallet
    assert_equal "~ 9.66 USD", publisher_converted_overall_balance(publisher)
    assert_equal "0.00", publisher_overall_bat_balance(publisher)
    def publisher.only_user_funds?
      false
    end

    def publisher.allowed_to_create_referrals?
      true
    end
    assert_equal "58.22", publisher_overall_bat_balance(publisher)

    publisher = FakePublisher.new(
      rates: {},
      accounts: [],
      transactions: [],
      uphold_connection: {default_currency: "USD"}
    )

    assert_equal "USD unavailable", publisher_converted_overall_balance(publisher)
  end

  test "uphold_status_class returns a css class that corresponds to a publisher's uphold_status" do
    publisher = OpenStruct.new
    publisher.uphold_connection = OpenStruct.new

    publisher.uphold_connection.uphold_status = :verified
    assert_equal "uphold-complete", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :access_parameters_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :code_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :reauthorization_needed
    assert_equal "uphold-reauthorization-needed", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = :unconnected
    assert_equal "uphold-unconnected", uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = UpholdConnection::UpholdAccountState::RESTRICTED
    assert_equal "uphold-" + UpholdConnection::UpholdAccountState::RESTRICTED.to_s, uphold_status_class(publisher)

    publisher.uphold_connection.uphold_status = UpholdConnection::UpholdAccountState::BLOCKED
    assert_equal "uphold-complete", uphold_status_class(publisher)
  end

  test "#next_deposit_date when it is midnight UTC displays the current month" do
    date = DateTime.parse("2019-05-01T00:00:00+0000")
    assert_equal next_deposit_date(today: date), "May 13th"
  end

  test "#next_deposit_date when it is midnight PST displays current month" do
    date = DateTime.parse("2019-05-01T00:00:00-0800")
    assert_equal next_deposit_date(today: date), "May 13th"
  end

  test "has_balance yes b/c has referral" do
    accounts = [
      {
        "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
        "account_type" => "owner",
        "balance" => "0.10"
      }
    ]
    transactions = []
    fake_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "USD")
    publisher = mock
    publisher.expects(:wallet).at_least_once.returns(fake_wallet)
    assert fake_wallet.referral_balance.amount_usd > 0
    assert has_balance?(publisher)
  end

  test "has_balance yes b/c has contribution" do
    accounts = [
      {
        "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
        "account_type" => "channel",
        "balance" => "0.10"
      }
    ]
    transactions = []
    fake_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "USD")
    publisher = mock
    publisher.expects(:wallet).returns(fake_wallet).at_least_once
    assert fake_wallet.contribution_balance.channel_amounts_usd[0] > 0
    assert has_balance?(publisher)
  end

  test "does not have balance" do
    accounts = [
      {
        "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
        "account_type" => "channel",
        "balance" => "0.000000009"
      }
    ]
    transactions = []
    fake_wallet = Eyeshade::Wallet.new(rates: rates, accounts: accounts, transactions: transactions, default_currency: "BAT")
    publisher = mock
    publisher.expects(:wallet).returns(fake_wallet).at_least_once
    refute has_balance?(publisher)
  end
end
