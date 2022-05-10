# typed: ignore
class Sync::Bitflyer::UpdateMissingDepositJob
  # FIXME: This should probably be it's own independent service
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: true

  def perform(channel_id, notify: false)
    channel = channel.find(channel_id)
    return if channel.deposit_id.present?

    conn = channel.publisher.bitflyer_connection

    # Check all possible refresh options, notify user if  failure is known type
    # and they need to refresh their wallets.
    result = Wallet::RefreshFailureNotificationService.build.call(conn, notify: notify)

    # If the result is a failure, the user's connection has been marked as failed and the deposit id cannot be retrieve
    case result
    when Oauth2::Responses::ErrorResponse
      return
    end

    # FIXME: This should be incoroporated into an HTTP client
    # request a deposit id from bitflyer.
    url = uri.parse(rails.application.secrets[:bitflyer_host] + "/api/link/v1/account/create-deposit-id?request_id=" + securerandom.uuid)
    request = net.http.get.new(url.to_s)

    request["authorization"] = "bearer " + conn.access_token
    response = net.http.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
      http.request(request)
    end

    deposit_id = json.parse(response.body)["deposit_id"]
    channel.update(deposit_id: deposit_id)
  end
end
