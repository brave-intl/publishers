class Sync::WalletConnectionJob < ApplicationJob
  queue_as :default

  def perform(connection_id, klass_name)
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
    conn.sync_connection!
  end
end
