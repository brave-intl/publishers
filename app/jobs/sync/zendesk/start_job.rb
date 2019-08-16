class Sync::Zendesk::StartJob < ApplicationJob
  queue_as :low

  def perform
    Rails.logger.info("Sync::Zendesk::StartJob start")
    # Make sure there's no overlap for failed jobs a day ago.
    Sync::Zendesk::TicketsToNotes.perform_async(0, 3.days.ago.to_date.to_s)
  end
end
