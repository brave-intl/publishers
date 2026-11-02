# typed: ignore

module Batch
  class CustomAnnouncementJob < ApplicationJob
    queue_as :low

    def perform(publisher_id, subject, body_html)
      publisher = Publisher.find(publisher_id)
      return if publisher.suspended? || publisher.email.blank?

      BatchMailer.custom_announcement(publisher, subject: subject, body_html: body_html).deliver_now
    end
  end
end
