# typed: true

class Bitflyer::UpdateDepositIdService < BuilderBaseService
  include Oauth2::Responses

  def self.build
    new
  end

  def call(channel)
    return shrug("NOOP: Deposit id was present on the channel.") if channel.deposit_id.present?

    conn = channel.bitflyer_connection

    return shrug("NOOP: No bitflyer connection detected.") if conn.nil?

    result = conn.refresh_authorization!

    # Man exhaustiveness checking is awesome.
    case result
    when BitflyerConnection
      # FIXME: Ideally this would be part of it's own client
      url = URI.parse(Rails.application.credentials[:bitflyer_host] + "/api/link/v1/account/create-deposit-id?request_id=" + SecureRandom.uuid)
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
    when BFailure
      result
    when ErrorResponse
      BFailure.new(errors: [result])
    when Oauth2::AuthorizationCodeBase
      raise
    else
      raise result
    end
  end
end
