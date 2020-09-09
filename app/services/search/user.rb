# frozen_string_literal: true

module Search
  class User < Base
    INDEX_NAME = "publishers_#{Rails.env}"
    INDEX_ALIAS = "publishers_#{Rails.env}_alias"
    MAPPINGS = JSON.parse(File.read("config/elasticsearch/mappings/publisher.json"), symbolize_names: true).freeze

    class << self
      def search_documents(query_string)
        results = search(body: query(query_string))
        results.dig("hits", "hits").map { |doc| doc.dig("_source") }
      end

      private

      def query(query_string)
        {
          query: {
            simple_query_string: {
              query: query_string,
              analyze_wildcard: true,
              lenient: true,
            },
          },
        }
      end

      def index_settings
        if Rails.env.production?
          {
            number_of_shards: 1,
            number_of_replicas: 1,
          }
        else
          {
            number_of_shards: 1,
            number_of_replicas: 0,
          }
        end
      end
    end
  end
end
