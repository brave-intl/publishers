# Used by the PublisherWalletGetter to retrieve balances
class PublisherBalanceGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher 
  end

  def perform
    return [] if publisher.channels.verified.empty?
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    accounts_response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.options.params_encoder = Faraday::FlatParamsEncoder
      request.url("v1/balances?account=#{URI.escape(publisher.owner_identifier)}#{channels_query_string}")
    end

    accounts = JSON.parse(accounts_response.body)

    complete_accounts = fill_in_missing_accounts(accounts)
    complete_accounts

  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
    :unavailable
  end

  def perform_offline
    fill_in_missing_accounts([])
  end

  private
  
  # TODO: Do not use details.author_identifier when all twitch#author is used everywhere 
  def channels_query_string
    return "" if publisher.channels.verified.count == 0
    publisher.channels.verified.map { |channel|
      if channel.details_type == "TwitchChannelDetails" && !Rails.env.test?
        channel_id = channel.details.author_identifier
      else
        channel_id = channel.details.channel_identifier
      end
      "&account=#{URI.escape(channel_id)}"}.reduce(:+)
  end

  # Eyeshade may return a 0 balance or an empty response for accounts (channel and owner)
  # with no balance, so we must fill in these values
  def fill_in_missing_accounts(accounts)
    # Find all of the publisher's verified channel ids
    # TODO: Remove details.author_identifier when all twitch#author is used everywhere
    verified_channel_ids = publisher.channels.verified.map do |channel|
      if channel.details_type == "TwitchChannelDetails" && !Rails.env.test?
        channel.details.author_identifier
      else
        channel.details.channel_identifier
      end
    end

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
        "account_id" => "#{channel_id}",
        "account_type" => "channel",
        "balance" => "0.00",
      }
    end

    # Fill in missing owner account if needed
    unless accounts_include_owner_account
      accounts.push({
        "account_id" => "#{publisher.owner_identifier}",
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
