class Sync::Uphold::RefreshAccessTokenJob
  include Sidekiq::Worker

  def perform(uphold_connection_id)
    connection = UpholdConnection.find(uphold_connection_id)
    Uphold::Refresher.build.call(uphold_connection: connection)
  end
end
