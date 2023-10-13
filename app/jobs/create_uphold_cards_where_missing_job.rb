# typed: false

# Creates the Uphold Cards for recently-logged-in publishers that don't have one but should
class CreateUpholdCardsWhereMissingJob < ApplicationJob
  queue_as :default

  def perform(publishers = [])
    if publishers.blank?
      publishers = Publisher.uphold_selected_provider_updated_recently.with_verified_channel.not_suspended
    end

    publishers.each { |publisher| CreateUpholdCardsJob.perform_later(publisher.selected_wallet_provider_id) }
  end
end
