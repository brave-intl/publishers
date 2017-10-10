# Verify all Publishers created in past 2 weeks with brave_publisher_id
class VerifyPublisher < ApplicationJob
  queue_as :default

  require "faraday"
  rescue_from(Faraday::ResourceNotFound) do
    Rails.logger.warn("PublisherVerifier 404; publisher might not exist in eyeshade.")
  end

  def perform(brave_publisher_id:)
    PublisherVerifier.new(
      attended: false,
      brave_publisher_id: brave_publisher_id,
    ).perform
  end
end
