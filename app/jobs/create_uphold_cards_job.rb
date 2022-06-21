# typed: false
# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  include Uphold::Types

  queue_as :default

  def perform(uphold_connection_id:)
    conn = UpholdConnection.find(uphold_connection_id)
    result = Uphold::FindOrCreateCardService.build.call(conn)

    case result
    when UpholdCard
      return conn if result&.id == conn.address
      conn.update!(address: result.id)
      conn
    end
  end
end
