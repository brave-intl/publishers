# typed: true
require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  extend T::Sig

  attr_reader :publisher

  RATES_CACHE_KEY = "rates_cache".freeze

  sig { params(publisher: Publisher, include_transactions: T::Boolean).void }
  def initialize(publisher:, include_transactions: true)
    @publisher = publisher
    @include_transactions = include_transactions
  end

  sig { returns(T.nilable(Eyeshade::Wallet)) }
  def perform
    Eyeshade::Wallet.new(
      rates: rates,
      accounts: accounts,
      transactions: transactions,
      default_currency: publisher.selected_wallet_provider&.default_currency
    )
  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  private

  sig { returns(PublisherBalanceGetter::RESULT_TYPE) }
  def accounts
    PublisherBalanceGetter.new(publisher: @publisher).perform
  end

  sig { returns(Ratio::Ratio::RESULT_TYPE) }
  def rates
    # Cache the ratios every minute. Rates are used for display purposes only.
    Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 1.minute) do
      rates = Ratio::Ratio.new.relative(currency: "BAT")
      # (Jon Staples) There is some ambiguity was to what the expected output of Ratio.relative is.
      # Here I fetch payload if it exists, otherwise I return rates.
      # Eyeshade::Wallet.initialize prior to adding in Sorbet type checking expected an object
      # with key payload that corresponded to T::Hash[String, BigDecimal] (or a Rates) type.
      rates.fetch("payload", rates)
    end
  end

  def transactions
    return [] unless @include_transactions
    PublisherTransactionsGetter.new(publisher: @publisher).perform
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
