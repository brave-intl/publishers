# typed: false

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

    Wallet::RefreshFailureNotificationService.build.call(conn, notify: notify)
  end
end
