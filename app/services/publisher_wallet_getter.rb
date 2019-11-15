require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  CACHE_TIME = 1.hours

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    Eyeshade::Wallet.new(
      rates: rates,
      accounts: balance,
      transactions: transactions,
      uphold_connection: publisher.uphold_connection
    )

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  rescue PublisherBalanceGetter::UnavailableBalance => e
    Rails.logger.warn("PublisherWalletGetter #unavailable balance: #{e}")
    nil
  end

  private

  def rates
    Rails.cache.fetch("ratios_relative_cache", expires_in: CACHE_TIME) do
      Ratio::Ratio.new.relative(currency: "BAT")
    end
  end

  def balance
    Rails.cache.fetch("#{publisher.owner_identifier}/balance", expires_in: CACHE_TIME) do
      PublisherBalanceGetter.new(publisher: publisher).perform
    end
  end

  def transactions
    Rails.cache.fetch("#{publisher.owner_identifier}/transactions", expires_in: CACHE_TIME) do
      PublisherTransactionsGetter.new(publisher: @publisher).perform
    end
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
