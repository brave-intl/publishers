class BitflyerRefreshJob < ApplicationJob
  queue_as :scheduler

  # https://docs.gemini.com/rest-api/#rate-limits
  # 0.1 requests/second
  def perform(wait: 0.1, limit: 5000, notify: false, async: false)
    count = 0
    base_query = limit.present? ? BitflyerConnection.limit(limit) : BitflyerConnection

    base_query.refreshable.select(:id).find_in_batches do |batch|
      batch.each do |connection|
        count += 1

        if async
          Oauth2RefreshJob.perform_later(connection.id, BitflyerConnection.name, notify: notify)
        else
          Oauth2RefreshJob.new.perform(connection.id, BitflyerConnection.name, notify: notify)
        end

        sleep(wait) if wait
      end
    end

    count
  end
end
