class Sync::LaunchTokenRefreshJobsJob
  include Sidekiq::Worker

  def perform
    UpholdConnection.with_details.all.each do |uphold_connection|
      details = JSON.parse(uphold_connection.uphold_access_parameters)
      refresh_token = details['refresh_token']
      if refresh_token
        Sync::Uphold::RefreshAccessTokenJob.perform_async(uphold_connection.id)
      end
    end
  end
end
