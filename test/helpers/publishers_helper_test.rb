require 'test_helper'
require 'eyeshade/wallet'

class PublishersHelperTest < ActionView::TestCase
  # test "should render brave publisher id as a link" do
  #   publisher = publishers(:default)
  #   assert_dom_equal %{<a href="http://#{publisher.brave_publisher_id}">#{publisher.brave_publisher_id}</a>},
  #                    link_to_brave_publisher_id(publisher)
  # end

  test "publisher_converted_balance should return nothing for unset publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = nil
    publisher.save
    assert_dom_equal %{}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return nothing for BAT publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "BAT"
    publisher.save
    assert_dom_equal %{}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return something for set publisher currency" do
    publisher = publishers(:default)
    publisher.default_currency = "USD"
    publisher.save
    assert_dom_equal %{~ 9001.00 USD}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return `CURRENCY unavailable` when no wallet is set" do
    class FakePublisher
      attr_reader :default_currency, :wallet

      def initialize(wallet_json:)
        @wallet = Eyeshade::Wallet.new(wallet_json: wallet_json, channel_json: {}) if wallet_json
        @default_currency = 'USD'
      end
    end

    publisher = FakePublisher.new(
      wallet_json: {
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
    assert_dom_equal %{~ 9001.00 USD}, publisher_converted_balance(publisher)

    publisher = FakePublisher.new(
      wallet_json: nil
    )

    assert_nil publisher.wallet
    assert_equal "USD unavailable", publisher_converted_balance(publisher)
  end

  test "can extract the uuid from an owner_identifier" do
    assert_equal "b8317d8a-78a4-48a6-9eeb-a2674c6455c4", publisher_id_from_owner_identifier("publishers#uuid:b8317d8a-78a4-48a6-9eeb-a2674c6455c4")
  end

  test "publisher_humanize_balance should return a formatted & converted wallet balance, last settlement balances do not apply fee" do
    class FakePublisher
      attr_reader :default_currency, :wallet

      def initialize(wallet_json:)
        @wallet = Eyeshade::Wallet.new(wallet_json: wallet_json, channel_json: {}) if wallet_json
        @default_currency = 'USD'
      end
    end

    publisher = FakePublisher.new(
      wallet_json: {
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
      }
    )
    assert_not_nil publisher.wallet
    assert_equal "9001.00", publisher_humanize_balance(publisher, "USD")

    # ensure last settlement balance does not have fee applied
    assert_equal publisher_humanize_last_settlement(publisher, "BAT"), "405.52"

    # ensure publisher_converted_last_settlement does not have fee applied
    assert_equal publisher_converted_last_settlement(publisher), "~ 95.86 USD"

    publisher = FakePublisher.new(
      wallet_json: nil
    )

    assert_nil publisher.wallet
    assert_equal "Unavailable", publisher_humanize_balance(publisher, "USD")
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

    publisher.uphold_status = :incomplete
    assert_equal "uphold-incomplete", uphold_status_class(publisher)
  end

  test "next settlement date is current month if <= 8th, otherwise next month" do
    assert_equal "June 8th", next_deposit_date(DateTime.parse("June 7, 2018"))
    assert_equal "June 8th", next_deposit_date(DateTime.parse("June 8, 2018"))
    assert_equal "July 8th", next_deposit_date(DateTime.parse("June 9, 2018"))
  end
end
