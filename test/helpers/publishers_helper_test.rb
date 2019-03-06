require 'test_helper'
require 'eyeshade/wallet'

class PublishersHelperTest < ActionView::TestCase
  # test "should render brave publisher id as a link" do
  #   publisher = publishers(:default)
  #   assert_dom_equal %{<a href="http://#{publisher.brave_publisher_id}">#{publisher.brave_publisher_id}</a>},
  #                    link_to_brave_publisher_id(publisher)
  # end

  test "publisher_converted_overall_balance should return nothing for unset publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = nil
    publisher.save
    assert_dom_equal %{}, publisher_converted_overall_balance(publisher)
  end

  test "publisher_converted_overall_balance should return nothing for BAT publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "BAT"
    publisher.save
    assert_dom_equal %{}, publisher_converted_overall_balance(publisher)
  end

  test "publisher_converted_overall_balance should return something for set publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "USD"
    publisher.save

    assert_dom_equal %{~ 0.00 USD}, publisher_converted_overall_balance(publisher) # 0 balance because this publisher has no channels
  end

  class FakePublisher
    attr_reader :default_currency, :wallet

    def initialize(wallet_info:, accounts: [], transactions: [])
      @wallet = Eyeshade::Wallet.new(wallet_info: wallet_info, accounts: accounts, transactions: transactions) if wallet_info
      @default_currency = 'USD'
    end

    def become_subclass
      self
    end

    def partner?
      false
    end
  end

  test "publisher_converted_overall_balance should return `CURRENCY unavailable` when no wallet is set" do

    publisher = FakePublisher.new(
      wallet_info: {
        "status" => {
          "provider" => "uphold"
        },
        "contributions" => {
          "amount" => "9001.00",
          "currency" => "USD",
          "altcurrency" => "BAT",
          "probi" => "38077497398351695427000"
        },
        "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
        },
        "wallet" => {
          "provider" => "uphold",
          "authorized" => true,
          "defaultCurrency" => 'USD',
          "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
        }
      }
    )

    assert_not_nil publisher.wallet
    assert_dom_equal %{~ 0.00 USD}, publisher_converted_overall_balance(publisher)

    publisher = FakePublisher.new(
      wallet_info: nil
    )

    assert_nil publisher.wallet
    assert_equal "USD unavailable", publisher_converted_overall_balance(publisher)
  end

  test "can extract the uuid from an owner_identifier" do
    assert_equal "b8317d8a-78a4-48a6-9eeb-a2674c6455c4", publisher_id_from_owner_identifier("publishers#uuid:b8317d8a-78a4-48a6-9eeb-a2674c6455c4")
  end

  test "publishers_last_settlement_balance should return a formatted & converted wallet balance, last settlement balances do not apply fee" do
    publisher = FakePublisher.new(
      wallet_info: {
        "status" => {
          "provider" => "uphold"
        },
        "contributions" => {
          "amount" => "9001.00",
          "currency" => "USD",
          "altcurrency" => "BAT",
          "probi" => "38077497398351695427000"
        },
        "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
        },
        "lastSettlement"=>
          {"altcurrency"=>"BAT",
           "currency"=>"USD",
           "probi"=>"405520562799219044167",
           "amount"=>"69.78",
           "timestamp"=>1536361540000},
        "wallet" => {
          "provider" => "uphold",
          "authorized" => true,
          "defaultCurrency" => 'USD',
          "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
        }
      },
      accounts: [
        {
          "account_id" => "publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "account_type" => "owner",
          "balance" => "58.217204799751874334"
        }
      ],
      transactions:[
        {
          "created_at" => "2018-11-07 00:00:00 -0800",
          "description"=>"payout for referrals",
          "channel"=>"publishers#uuid:0a16cdb5-90c4-437a-b4fd-1445f82b2f6b",
          "amount"=>"-94.617182149806375904",
          "settlement_currency"=>"ETH",
          "settlement_amount"=>"18.81",
          "type"=>"referral_settlement"
        }
      ]
    )
    assert_not_nil publisher.wallet
    assert_equal "~ 13.76 USD", publisher_converted_overall_balance(publisher)
    assert_equal "58.22", publisher_overall_bat_balance(publisher)

    # ensure last settlement balance does not have fee applied
    assert_equal publisher_last_settlement_bat_balance(publisher), "18.81"

    # ensure publisher_converted_last_settlement does not have fee applied
    assert_equal publisher_converted_last_settlement_balance(publisher), "~ 0.01 ETH"

    publisher = FakePublisher.new(
      wallet_info: nil,
      accounts: [],
      transactions: []
    )

    assert_nil publisher.wallet
    assert_equal "USD unavailable", publisher_converted_overall_balance(publisher)
  end

  test "uphold_status_class returns a css class that corresponds to a publisher's uphold_status" do
    class PublisherWithUpholdStatus
      attr_accessor :uphold_status
    end

    publisher = PublisherWithUpholdStatus.new

    publisher.uphold_status = :verified
    assert_equal "uphold-complete", uphold_status_class(publisher)

    publisher.uphold_status = :access_parameters_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_status = :code_acquired
    assert_equal "uphold-processing", uphold_status_class(publisher)

    publisher.uphold_status = :reauthorization_needed
    assert_equal "uphold-reauthorization-needed", uphold_status_class(publisher)

    publisher.uphold_status = :unconnected
    assert_equal "uphold-unconnected", uphold_status_class(publisher)

    publisher.uphold_status = Publisher::UpholdAccountState::RESTRICTED
    assert_equal "uphold-" + Publisher::UpholdAccountState::RESTRICTED.to_s, uphold_status_class(publisher)

    publisher.uphold_status = Publisher::UpholdAccountState::BLOCKED
    assert_equal "uphold-complete", uphold_status_class(publisher)
  end

  test "next settlement date is current month if <= 8th, otherwise next month" do
    assert_equal "June 8th", next_deposit_date(DateTime.parse("June 7, 2018"))
    assert_equal "June 8th", next_deposit_date(DateTime.parse("June 8, 2018"))
    assert_equal "July 8th", next_deposit_date(DateTime.parse("June 9, 2018"))
  end
end
