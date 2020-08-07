# frozen_string_literal: true

module Search
  class Publisher < Base
    INDEX_NAME = "publishers_#{Rails.env}"
    INDEX_ALIAS = "publishers_#{Rails.env}_alias"
    MAPPINGS = JSON.parse(File.read("config/elasticsearch/mappings/publisher.json"), symbolize_names: true).freeze

    class << self
      def index(publisher_id, serialized_data)
        SearchClient.index(
          id: publisher_id,
          index: INDEX_ALIAS,
          body: serialized_data,
        )
      end

      private

      def index_settings
        {
          number_of_shards: 1,
          number_of_replicas: 0,
        }
      end
    end
  end
end
