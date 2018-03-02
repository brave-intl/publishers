require "eyeshade/wallet"

# Query wallet balance from Eyeshade
class PublisherWalletGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    wallet_response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/owners/#{URI.escape(publisher.owner_identifier)}/wallet")
    end

    channel_responses = {}
    publisher.channels.each do |channel|
      identifier =  channel.details.channel_identifier
      channel_responses[identifier] = connection.get do |request|
        request.headers["Authorization"] = api_authorization_header
        request.url("/v2/publishers/#{URI.escape(identifier)}/balance")
      end
    end

    wallet_hash = JSON.parse(wallet_response.body)

    channel_hash = {}
    channel_responses.each do |identifier, response|
      channel_hash[identifier] = JSON.parse(response.body)
    end

    Eyeshade::Wallet.new(
      wallet_json: wallet_hash,
      channel_json: channel_hash
    )
  rescue Faraday::Error => e
    Rails.logger.warn("PublisherWalletGetter #perform error: #{e}")
    nil
  end

  def perform_offline
    Rails.logger.info("PublisherWalletGetter returning offline stub balance.")

    channel_json = {}
    @publisher.channels.each do |channel|
      channel_json[channel.details.channel_identifier] = {
        "amount" => "9001.00",
        "currency" => "USD",
        "altcurrency" => "BAT",
        "probi" => "38077497398351695427000",
        "rates" => {
          "BTC" => 0.00005418424016883016,
          "ETH" => 0.000795331082073117,
          "USD" => 0.2363863335301452,
          "EUR" => 0.20187818378874756,
          "GBP" => 0.1799810085548496
        }
      }
    end

    Eyeshade::Wallet.new(
      wallet_json: {
        "status" => {
            "provider" => "uphold",
            # "action" => "re-authorize"
            # "action" => "authorize"
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
      },
      channel_json: channel_json
    )
  end

  private

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
