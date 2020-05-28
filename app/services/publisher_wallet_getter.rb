require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  RATES_CACHE_KEY = "rates_cache".freeze

  def initialize(publisher:)
    @publisher = publisher
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
      uphold_connection: publisher.uphold_connection
    )

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  private

  def rates
    Ratio::Ratio.relative_cached(currency: "BAT")
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
