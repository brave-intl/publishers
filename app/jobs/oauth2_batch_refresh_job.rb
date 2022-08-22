class Oauth2BatchRefreshJob < ApplicationJob
  queue_as :scheduler

  # https://docs.gemini.com/rest-api/#rate-limits
  # 0.1 requests/second
  def perform(wait: 0.1, limit: 5000, notify: false, async: true)
    klass = set_klass

    limit = set_limit.present? ? set_limit : limit

    count = 0
    base_query = limit.present? ? klass.limit(limit) : klass

    base_query.refreshable.select(:id).find_in_batches do |batch|
      batch.each do |connection|
        count += 1

        if async
          Oauth2RefreshJob.perform_later(connection.id, klass.name, notify: notify)
        else
          Oauth2RefreshJob.new.perform(connection.id, klass.name, notify: notify)
        end
        sleep(wait) if wait
      end
    end

    count
  end

  private

  def set_klass
    raise NotImplementedError
  end

  def set_limit
    nil
  end
end
