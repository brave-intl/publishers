class DisconnectUpholdJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    PublisherWalletDisconnector.new(publisher: publisher).perform
  end
end
