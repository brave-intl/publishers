# typed: false

class CleanStaleUpholdDataJob < ApplicationJob
  queue_as :scheduler

  def perform
    # clear uphold codes sitting for over 5 minutes
    connections = UpholdConnection.has_stale_uphold_code
    n = 0
    connections.each do |connection|
      raise if connection.uphold_status != :code_acquired
      connection.uphold_code = nil
      connection.save!
      n += 1
    end
  end
end
