# typed: false

# Creates the Uphold Cards for recently-logged-in publishers that don't have one but should
class CreateUpholdCardsWhereMissingJob < ApplicationJob
  queue_as :default

  def perform(publishers:)
    if publishers.blank?
      publishers = Publisher.uphold_selected_provider.with_verified_channel.not_suspended.logged_in_recently
    end

    publishers.each { |publisher| CreateUpholdCardsJob.perform_later(uphold_connection_id: publisher.selected_wallet_provider_id) }
  end
end
