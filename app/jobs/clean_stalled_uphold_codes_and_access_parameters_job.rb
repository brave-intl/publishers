class CleanStalledUpholdCodesAndAccessParametersJob < ApplicationJob
  queue_as :scheduler

  def perform
    # clear uphold codes sitting for over 5 minutes   
    publishers = Publisher.has_stalled_uphold_code
    n = 0
    publishers.each do |publisher|
      raise if publisher.uphold_status != :code_acquired
      publisher.uphold_code = nil
      publisher.uphold_updated_at = Time.now
      publisher.save!
      n += 1
      Rails.logger.info("Cleaned stalled uphold code for #{publisher.brave_publisher_id}.")
    end
    Rails.logger.info("CleanStalledUpholdCodesAndAccessParametersJob cleared #{n} stalled uphold codes.")

    # clear uphold access params sitting for over 2 hours
    publishers = Publisher.has_stalled_uphold_access_parameters
    n = 0
    publishers.each do |publisher|
      raise if publisher.uphold_status != :access_parameters_acquired
      publisher.uphold_access_parameters = nil
      publisher.uphold_updated_at = Time.now
      publisher.save!
      Rails.logger.info("Cleaned stalled uphold access parameters for #{publisher.brave_publisher_id}.")
    end
    Rails.logger.info("CleanStalledUpholdCodesAndAccessParametersJob cleared #{n} stalled uphold access parameters.")
  end
end
