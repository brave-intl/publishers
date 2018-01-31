class DeletePublisherChannelJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:, channel_identifier:)
    publisher = Publisher.find(publisher_id)

    PublisherChannelDeleter.new(publisher: publisher, channel_identifier: channel_identifier).perform
  end
end
