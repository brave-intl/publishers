class RegisterPublisherWithMailChimpJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:, prior_email: nil)
    publisher = Publisher.find(publisher_id)
    MailChimpRegistrar.new(publisher: publisher, prior_email: prior_email).perform
  rescue => e
    require "sentry-raven"
    Raven.capture_exception(e)
  end
end