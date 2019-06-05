# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    unless publisher.uphold_connection.can_create_uphold_cards?
      Rails.logger.info("Could not create uphold card for publisher #{publisher.id}.")
      SlackMessenger.new(message: "Could not create uphold card for publisher #{publisher.id}.").perform
      return
    end

    default_currency = publisher.default_currency

    if publisher.wallet.address.blank?
      UpholdServices::CardCreationService.new(publisher: publisher,
                                              currency_code: default_currency).perform
    end

    if default_currency != publisher.wallet.default_currency
      PublisherDefaultCurrencySetter.new(publisher: publisher).perform
    end
  end
end
