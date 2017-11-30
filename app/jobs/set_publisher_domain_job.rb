class SetPublisherDomainJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    PublisherDomainSetter.new(publisher: publisher).perform

    publisher.save!
  end
end
