class UploadDefaultCurrencyJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    PublisherDefaultCurrencySetter.new(publisher: publisher).perform
  end
end
