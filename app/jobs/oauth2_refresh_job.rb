# typed: false

class Oauth2RefreshJob < ApplicationJob
  queue_as :default

  def perform(connection_id, klass_name, notify: false)
    case klass_name
    when "UpholdConnection"
      provider = "Uphold"
      klass = UpholdConnection
    when "GeminiConnection"
      provider = "Gemini"
      klass = GeminiConnection
    when "BitflyerConnection"
      provider = "Bitflyer"
      klass = BitflyerConnection
    else
      raise StandardError.new("Invalid klass_name: #{klass_name}")
    end

    conn = klass.find_by_id!(connection_id)
    result = conn.refresh_authorization!

    return result if !notify

    case result
    when Oauth2::Responses::ErrorResponse
      PublisherMailer.wallet_refresh_failure(conn.publisher, provider).deliver_now
      conn.record_refresh_failure_notification!
    end

    result
  end
end
