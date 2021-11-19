# typed: false
require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  RATES_CACHE_KEY = "rates_cache".freeze

  def initialize(publisher:, include_transactions: true)
    @publisher = publisher
    @include_transactions = include_transactions
  end

  def perform
    if publisher.channels.verified.present? || publisher.browser_user?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform
      return if accounts == :unavailable
    else
      accounts = []
    end

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

  def rates
    # Cache the ratios every minute. Rates are used for display purposes only.
    Rails.cache.fetch(RATES_CACHE_KEY, expires_in: 1.minute) do
      Ratio::Ratio.new.relative(currency: "BAT")
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
