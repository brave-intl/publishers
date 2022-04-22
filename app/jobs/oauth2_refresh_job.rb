# typed: true

class Oauth2RefreshJob < ApplicationJob
  queue_as :default

  def perform(connection_id, klass_name, notify: false)
    case klass_name
    when "UpholdConnection"
      klass = UpholdConnection
    when "GeminiConnection"
      klass = GeminiConnection
    when "BitflyerConnection"
      klass = BitflyerConnection
    else
      raise StandardError.new("Invalid klass_name: #{klass_name}")
    end

    conn = klass.find_by_id!(connection_id)
    result = conn.refresh_authorization!

    return result if !notify

    case result
    when Oauth2::Responses::ErrorResponse
      PublisherMailer.wallet_refresh_failure(conn.publisher).deliver_now
      conn.record_refresh_failure_notification!
    end

    result
  end
end
