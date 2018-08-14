# Used by the PublisherWalletGetter to retrieve balances
class PublisherBalanceGetter < BaseApiClient
  attr_reader :publisher

  def initialize(publisher:)
    @publisher = publisher
  end

  def perform
    return [] if publisher.channels.verified.empty?
    return perform_offline if Rails.application.secrets[:api_eyeshade_offline]

    channel_balances_response = connection.get do |request|
      request.headers["Authorization"] = api_authorization_header
      request.url("/v1/balances?account=#{URI.escape(publisher.owner_identifier)}#{URI.escape(channels_query_string)}")
    end

    channel_balances = JSON.parse(channel_balances_response.body)

    # Eyeshade returns an empty response for verified channels
    # with no balance, so we must fill in 0.00 balances

    # Find verified channel IDs with no balance
    verified_channel_ids = []
    publisher.channels.verified.each {|channel| verified_channel_ids.push(channel.details.channel_identifier)}

    channel_balances.each do |channel_balance|
      channel_identifier = channel_balance["account"]
      verified_channel_ids.delete(channel_identifier) if verified_channel_ids.include?(channel_identifier)
    end
    # Set balances to 0.00
    channel_balances += verified_channel_ids.map { |verified_channel_id| { "account" => "#{verified_channel_id}", "balance" => "0.00" } }
  
    channel_balances
  end

  def perform_offline
    @publisher.channels.verified.map { |channel| { "account" => "#{channel.details.channel_identifier}", "balance" => "#{rand(0..3000)}"} }
  end

  private

  def channels_query_string
    return "" if publisher.channels.verified.count == 0
    publisher.channels.verified.map { |channel| "&account=#{channel.details.channel_identifier}" }.reduce(:+)
  end

  def api_base_uri
    Rails.application.secrets[:api_eyeshade_base_uri]
  end

  def api_authorization_header
    "Bearer #{Rails.application.secrets[:api_eyeshade_key]}"
  end
end