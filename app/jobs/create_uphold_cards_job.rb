# typed: false
# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    conn = UpholdConnection.find(uphold_connection_id)
    card = conn.find_or_create_card!

    return if card and card.id == conn.address

    conn.update!(address: conn.id)
  end
end
