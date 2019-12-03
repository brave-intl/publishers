module Batch
  class EmailUpdateToUserJob < ApplicationJob
    queue_as :low

    def perform(publisher_id:)
      publisher = Publisher.find(publisher_id)
      return if publisher.suspended?

      BatchMailer.notification_for_kyc(publisher).deliver_now
    end
  end
end
