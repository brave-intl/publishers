class Oauth2BatchRefreshJob < ApplicationJob
  queue_as :scheduler

  def perform(wait: 0, limit: nil)
    count = 0
    [UpholdConnection].each do |klass|
      base_query = limit.present? ? klass.limit(limit) : klass

      # The idea here is I'm filling a queue to refresh tokens from each connection type
      # while adding a delay so I do not overwhelm the API rate limit of a given provider
      base_query.select(:id).find_in_batches do |batch|
        batch.each do |connection|
          count += 1
          # I'm using this job to call individual jobs so I can take advantage of retries/failover due to thinks like rate limits
          # I've used exactly this pattern before to handle mass email jobs, though I don't always wait between enqueing tasks.
          Oauth2RefreshJob.perform_later(connection.id, klass.name)
          sleep(wait)
        end
      end
    end

    count
  end
end
