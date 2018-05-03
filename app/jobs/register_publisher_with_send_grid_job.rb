class RegisterPublisherWithSendGridJob < ApplicationJob
  queue_as :default

  # SendGrid allows 3 POSTs per 2 seconds, but we'll stick with 1 per second for safety
  throttle threshold: 1, period: 1.second

  # Using positional arguments for issue with activejob-traffic_control
  def perform(publisher_id, prior_email = nil)
    publisher = Publisher.find(publisher_id)
    SendGridRegistrar.new(publisher: publisher, prior_email: prior_email).perform
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)

    # Retry later if the SendGrid rate limit was exceeded
    if e.is_a?(SendGrid::RateLimitExceeded)
      retry_job wait: 1.minute
    end
  end
end