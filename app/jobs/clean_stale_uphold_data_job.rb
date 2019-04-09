class CleanStaleUpholdDataJob < ApplicationJob
  queue_as :scheduler

  def perform
    require "sentry-raven"
    # clear uphold codes sitting for over 5 minutes
    publishers = Publisher.has_stale_uphold_code
    n = 0
    publishers.each do |publisher|
      raise if publisher.uphold_connection.uphold_status != :code_acquired
      publisher.uphold_connection.uphold_code = nil
      publisher.save!
      n += 1
      Rails.logger.info("Cleaned stalled uphold code for #{publisher.owner_identifier}.")
      Raven.capture_message("Cleaned stalled uphold code for #{publisher.owner_identifier}.")
    end
    Rails.logger.info("CleanStaleUpholdDataJob cleared #{n} stalled uphold codes.")

    # clear uphold access params sitting for over 2 hours
    publishers = Publisher.has_stale_uphold_access_parameters
    n = 0
    publishers.each do |publisher|
      raise if publisher.uphold_status != :access_parameters_acquired
      publisher.uphold_access_parameters = nil
      publisher.save!
      n += 1
      Rails.logger.info("Cleaned stalled uphold access parameters for #{publisher.owner_identifier}.")
      Raven.capture_message("Cleaned stalled uphold access parameters for #{publisher.owner_identifier}.")
    end
    Rails.logger.info("CleanStaleUpholdDataJob cleared #{n} stalled uphold access parameters.")
  end
end
