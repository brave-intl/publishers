class SetPublisherDomainJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    if publisher.brave_publisher_id_unnormalized
      PublisherDomainSetter.new(publisher: publisher).perform
      publisher.brave_publisher_id_unnormalized = nil
      publisher.save!
    end
  end
end
