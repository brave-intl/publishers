# Verify all Publishers created in past 2 weeks with brave_publisher_id
class VerifyPublisher < ActiveJob::Base
  queue_as :default

  def perform(brave_publisher_id:)
    PublisherVerifier.new(brave_publisher_id: brave_publisher_id).perform
  end
end
