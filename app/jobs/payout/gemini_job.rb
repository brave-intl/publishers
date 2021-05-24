module Payout
  class GeminiJob < ApplicationJob
    queue_as :scheduler

    def perform(should_send_notifications: false, payout_report_id: nil, publisher_ids: [])
      Payout::GeminiJobImplementation.build.call(
        should_send_notifications: should_send_notifications,
        payout_report_id: payout_report_id,
        publisher_ids: publisher_ids
      )
    end
  end
end
