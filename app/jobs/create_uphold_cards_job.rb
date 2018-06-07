# Creates the Uphold Cards for a publisher
class CreateUpholdCardsJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)
    
    raise unless publisher.can_create_uphold_cards?

    if publisher.should_create_default_currency_card?
      UpholdServices::CardCreationService.new(publisher: publisher,
                                              currency_code: publisher.default_currency).perform
    end

    if publisher.default_currency != "BAT" && publisher.should_create_bat_card?
      UpholdServices::CardCreationService.new(publisher: publisher, currency_code: "BAT").perform
    end      

    if publisher.should_update_eyeshade_default_currency?
      PublisherDefaultCurrencySetter.new(publisher: publisher).perform
    end
  end
end