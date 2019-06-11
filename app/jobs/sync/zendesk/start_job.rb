class Sync::Zendesk::StartJob < ApplicationJob
  def perform
    # Make sure there's no overlap for failed jobs a day ago.
    Sync::Zendesk::TicketsToNotes.perform_async(0, 3.days.ago.to_date.to_s)
  end
end
