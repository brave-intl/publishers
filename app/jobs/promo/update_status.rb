# Registers a single channel for a promo immediately after verification
module Promo
  class UpdateStatus < ApplicationJob
    queue_as :default

    def perform(id:, status:)
      client = Promo::Client.new

      # Remove previous states, this prevents from any unique index constraints from being violated
      states = client.owner_state.find(id: id)
      states.each do |state|
        client.owner_state.destroy(id: id, state: state)
      end

      if status == PublisherStatusUpdate::SUSPENDED
        client.owner_state.create(id: id, state: Promo::Models::OwnerState::State::SUSPEND)
      elsif status == PublisherStatusUpdate::ONLY_USER_FUNDS
        client.owner_state.create(id: id, state: Promo::Models::OwnerState::State::NO_UGP)
      end
    end
  end
end
