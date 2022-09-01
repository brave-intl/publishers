# typed: true

# Registers a single channel for a promo immediately after verification
module Promo
  class UpdateStatus < ApplicationJob
    queue_as :default

    def perform(id:, status:)
      # Remove previous states, this prevents from any unique index constraints from being violated
      states = PromoClient.owner_state.find(id: id)
      states.each do |state|
        PromoClient.owner_state.destroy(id: id, state: state)
      end

      if status == PublisherStatusUpdate::SUSPENDED
        PromoClient.owner_state.create(id: id, state: Promo::Models::OwnerState::State::SUSPEND)
      elsif status == PublisherStatusUpdate::ONLY_USER_FUNDS
        PromoClient.owner_state.create(id: id, state: Promo::Models::OwnerState::State::NO_UGP)
      end
    end
  end
end
