module Search
  class UserIndexJob
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform(publisher_id)
      user = Publisher.find(publisher_id)
      user.index_to_elasticsearch_now
    end
  end
end
