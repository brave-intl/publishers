# typed: false
# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    conn = UpholdConnection.find(uphold_connection_id)
    card = Uphold::FindOrCreateCardService.build.call(conn)
    return conn if card&.id == conn.address

    conn.update!(address: card.id)
    conn
  end
end
