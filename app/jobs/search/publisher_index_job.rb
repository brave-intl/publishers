module Search
  class PublisherIndexJob
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform(publisher_id)
      publisher = Publisher.find(publisher_id)
      publisher.index_to_elasticsearch_now
    end
  end
end
