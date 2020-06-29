class RegisterPublisherWithSendGridJob < ApplicationJob
  queue_as :low

  # Using positional arguments for issue with activejob-traffic_control
  def perform(publisher_id, prior_email = nil)
    publisher = Publisher.find(publisher_id)
    SendGridRegistrar.new(publisher: publisher, prior_email: prior_email).perform
  end
end
