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
    assert_dom_equal %{Approximately 9001.00 USD}, publisher_converted_balance(publisher)
  end

  test "publisher_converted_balance should return `Unavailable` when no wallet is set" do
    class FakePublisher
      attr_reader :default_currency, :wallet

      def initialize(wallet_json:)
        @wallet = Eyeshade::Wallet.new(wallet_json: wallet_json) if wallet_json
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
          "preferredCurrency" => 'USD',
          "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
        }
      }
    )
    assert_not_nil publisher.wallet
    assert_dom_equal %{Approximately 9001.00 USD}, publisher_converted_balance(publisher)

    publisher = FakePublisher.new(
      wallet_json: nil
    )

    assert_nil publisher.wallet
    assert_equal "Unavailable", publisher_converted_balance(publisher)
  end

  test "can extract the uuid from an owner_identifier" do
    assert_equal "b8317d8a-78a4-48a6-9eeb-a2674c6455c4", publisher_id_from_owner_identifier("publishers#uuid:b8317d8a-78a4-48a6-9eeb-a2674c6455c4")
  end

  test "publisher_humanize_balance should return a formatted & converted wallet balance" do
    class FakePublisher
      attr_reader :default_currency, :wallet

      def initialize(wallet_json:)
        @wallet = Eyeshade::Wallet.new(wallet_json: wallet_json) if wallet_json
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
          "preferredCurrency" => 'USD',
          "availableCurrencies" => [ 'USD', 'EUR', 'BTC', 'ETH', 'BAT' ]
        }
      }
    )
    assert_not_nil publisher.wallet
    assert_equal "9001.00", publisher_humanize_balance(publisher, "USD")

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
    assert_equal "uphold-status-verified", uphold_status_class(publisher)

    publisher.uphold_status = :access_parameters_acquired
    assert_equal "uphold-status-access-parameters-acquired", uphold_status_class(publisher)

    publisher.uphold_status = :code_acquired
    assert_equal "uphold-status-code-acquired", uphold_status_class(publisher)

    publisher.uphold_status = :unconnected
    assert_equal "uphold-status-unconnected", uphold_status_class(publisher)
  end
end
