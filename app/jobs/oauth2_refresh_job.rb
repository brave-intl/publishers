# typed: true

class Oauth2RefreshJob < ApplicationJob
  queue_as :default

  def perform(connection_id, klass_name)
    case klass_name
    when "UpholdConnection"
      klass = UpholdConnection
    when "GeminiConnection"
      klass = GeminiConnection
    else
      raise StandardError.new("Invalid klass_name: #{klass_name}")
    end

    klass.find_by_id!(connection_id).refresh_authorization!
  end
end
