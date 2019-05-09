class UploadUpholdAccessParametersJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    PublisherWalletSetter.new(publisher: publisher).perform

    publisher.uphold_connection.verify_uphold
  end
end
