module Search
  class UserIndexJob
    include Sidekiq::Worker

    sidekiq_options queue: :low

    def perform(publisher_id)
      return if Rails.application.secrets.elasticsearch_url.blank?
      user = Publisher.find(publisher_id)
      user.index_to_elasticsearch_now
    end
  end
end
