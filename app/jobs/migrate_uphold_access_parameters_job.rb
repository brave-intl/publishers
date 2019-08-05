# Temporary Job to migrate access parameters
class MigrateUpholdAccessParametersJob < ApplicationJob
  queue_as :low

  def perform(publisher_id:, parameters:, default_currency:)
    connection = UpholdConnection.find_by(publisher_id: publisher_id)
    if connection.present?

      updated = connection.update(
        uphold_access_parameters: parameters.to_json,
        default_currency: connection.publisher.default_currency || default_currency,
        default_currency_confirmed_at: connection.publisher.default_currency_confirmed_at || Time.now
      )

      was_successful = connection.sync_from_uphold!
      # Let's not queue up a job that will ultimately not work due to invalid access_parameters
      next unless was_successful

      connection.reload

      # Sync the uphold card or create it if the card is missing
      CreateUpholdCardsJob.perform_later(uphold_connection_id: connection.id)
    else
      Rails.logger.info("Couldn't find publisher #{publisher_id} in creator's database but exists on mongo owner's database (Probably not a big deal)")
    end
  end
end
