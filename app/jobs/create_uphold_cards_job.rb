# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)

    raise unless publisher.can_create_uphold_cards?

    default_currency = publisher.default_currency

    if publisher.wallet.address.blank?
      UpholdServices::CardCreationService.new(publisher: publisher,
                                              currency_code: default_currency).perform
    end

    if default_currency != "BAT" && publisher.wallet.address.blank?
      UpholdServices::CardCreationService.new(publisher: publisher, currency_code: "BAT").perform
    end

    if default_currency != publisher.wallet.default_currency
      PublisherDefaultCurrencySetter.new(publisher: publisher).perform
    end
  end
end
