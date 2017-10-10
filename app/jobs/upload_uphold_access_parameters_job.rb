class UploadUpholdAccessParametersJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    PublisherWalletSetter.new(publisher: publisher).perform

    publisher.verify_uphold
  end
end
