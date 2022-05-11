# typed: true

class Bitflyer::UpdateDepositIdService < BuilderBaseService
  include Wallet::Structs

  def self.build
    new
  end

  def call(channel, notify: false)
    return shrug("NOOP: Deposit id was present on the channel somehow") if channel.deposit_id.present?

    conn = channel.publisher.bitflyer_connection

    return shrug("NOOP: No bitflyer connection detected somehow") if conn.nil?
    return shrug("NOOP: Bitflyer connection invalid") if conn.oauth_refresh_failed

    result = Wallet::RefreshFailureNotificationService.build.call(conn, notify: notify)

    case result
    when FailedWithoutNotification, FailedWithNotification
      return result
    end

    # FIXME: Ideally this would be part of it's own client
    url = URI.parse(Rails.application.secrets[:bitflyer_host] + "/api/link/v1/account/create-deposit-id?request_id=" + SecureRandom.uuid)
    request = Net::HTTP::Get.new(url.to_s)

    request["Authorization"] = "Bearer " + conn.access_token
    response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
      http.request(request)
    end

    deposit_id = JSON.parse(response.body)["deposit_id"]
    channel.update!(deposit_id: deposit_id)

    # Passing the channel along mostly for debugging purposes
    # If I really care about/want the channel I will create an explicit
    # result type and pass it with a static type of Channel
    pass([channel])
  end
end
