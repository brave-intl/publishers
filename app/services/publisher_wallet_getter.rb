require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    if publisher.channels.verified.present?
      accounts = PublisherBalanceGetter.new(publisher: publisher).perform
      return if accounts == :unavailable
    else
      accounts = []
    end

    Eyeshade::Wallet.new(
      rates: Ratio::Ratio.new.relative(currency: "BAT"),
      accounts: accounts,
      transactions: PublisherTransactionsGetter.new(publisher: @publisher).perform,
      uphold_connection: publisher.uphold_connection
    )

  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
