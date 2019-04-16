class CleanStaleUpholdDataJob < ApplicationJob
  queue_as :scheduler

  def perform
    require "sentry-raven"
    # clear uphold codes sitting for over 5 minutes
    connections = UpholdConnection.has_stale_uphold_code
    n = 0
    connections.each do |connection|
      raise if connection.uphold_status != :code_acquired
      uphold_code = nil
      connection.save!
      n += 1
      Rails.logger.info("Cleaned stalled uphold code for #{connection.publisher.owner_identifier}.")
      Raven.capture_message("Cleaned stalled uphold code for #{connection.publisher.owner_identifier}.")
    end
    Rails.logger.info("CleanStaleUpholdDataJob cleared #{n} stalled uphold codes.")

    # clear uphold access params sitting for over 2 hours
    connections = UpholdConnection.has_stale_uphold_access_parameters
    n = 0
    connections.each do |connection|
      raise if connection.uphold_status != :access_parameters_acquired
      connection.uphold_access_parameters = nil
      connection.save!
      n += 1
      Rails.logger.info("Cleaned stalled uphold access parameters for #{connection.publisher.owner_identifier}.")
      Raven.capture_message("Cleaned stalled uphold access parameters for #{connection.publisher.owner_identifier}.")
    end
    Rails.logger.info("CleanStaleUpholdDataJob cleared #{n} stalled uphold access parameters.")
  end
end
