class GeminiRefreshJob < ApplicationJob
  queue_as :scheduler

  # https://docs.gemini.com/rest-api/#rate-limits
  # 0.1 requests/second
  def perform(wait: 0.1, limit: 5000, notify: false)
    count = 0
    base_query = limit.present? ? GeminiConnection.limit(limit) : GeminiConnection

    base_query.refreshable.select(:id).find_in_batches do |batch|
      batch.each do |connection|
        count += 1

        Oauth2RefreshJob.perform_later(connection.id, GeminiConnection.name, notify: notify)
        sleep(wait) if wait
      end
    end

    count
  end
end
