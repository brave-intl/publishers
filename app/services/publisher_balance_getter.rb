# typed: false

# Used by the PublisherWalletGetter to retrieve balances
class PublisherBalanceGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    accounts_response = connection.send(:post) do |req|
      req.options.open_timeout = 5
      req.options.timeout = 20
      req.url [api_base_uri, "/v1/accounts/balances"].join("")
      req.headers["Authorization"] = api_authorization_header
      req.headers["Content-Type"] = "application/json"
      req.body = JSON.dump({account: [publisher.owner_identifier] + channels_accounts, pending: true})
    end

    accounts = JSON.parse(accounts_response.body)
    fill_in_missing_accounts(accounts)
  rescue Faraday::ClientError => e
    Rails.logger.info("Error receiving eyeshade balance #{e.message}")
    :unavailable
  rescue => e
    LogException.perform(e)
    :unavailable
  end

  def perform_offline
    accounts = fill_in_missing_accounts([])
    accounts.each { |account| account["balance"] = "294.617182149806375904" }
  end

  private

  def channels_accounts
    publisher.channels.verified.map { |channel| channel.details.channel_identifier }
  end

  # Eyeshade may return a 0 balance or an empty response for accounts (channel and owner)
  # with no balance, so we must fill in these values
  def fill_in_missing_accounts(accounts)
    # Find all of the publisher's verified channel ids
    verified_channel_ids = publisher.channels.verified.map { |channel| channel.details.channel_identifier }

    # Find which verified channel ids have been included in the response
    account_ids = accounts.map { |account| account["account_id"] }

    # Find whether the owner account was included in the response
    accounts_include_owner_account = false
    accounts.each do |account|
      if account["account_type"] == "owner"
        accounts_include_owner_account = true
      end
    end

    # Fill in missing channel accounts if needed
    channel_ids_to_fill_in = verified_channel_ids.select { |verified_channel_id| account_ids.exclude?(verified_channel_id) }

    accounts += channel_ids_to_fill_in.map do |channel_id|
      {
        "account_id" => channel_id.to_s,
        "account_type" => "channel",
        "balance" => "0.00"
      }
    end

    # Fill in missing owner account if needed
    unless accounts_include_owner_account
      accounts.push({
        "account_id" => publisher.owner_identifier.to_s,
        "account_type" => "owner",
        "balance" => "0.00"
      })
    end

    accounts
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end
