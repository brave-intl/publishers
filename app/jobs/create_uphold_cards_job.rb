# typed: false
# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  include Uphold::Types

  queue_as :default

  def perform(uphold_connection_id:)
    conn = UpholdConnection.find(uphold_connection_id)
    card = conn.find_or_create_uphold_card!
    return conn if card&.id == conn.address

    conn.update!(address: card.id)
    conn
  end
end
