class ExchangeUpholdCodeForAccessTokenJob < ApplicationJob
  queue_as :default

  def perform(publisher_id:)
    publisher = Publisher.find(publisher_id)
    parameters = UpholdRequestAccessParameters.new(
        publisher: publisher
    ).perform

    if parameters
      publisher.uphold_access_parameters = parameters
      # The code acquired from https://uphold.com/authorize is only good for one request and times out in 5 minutes
      # it should now be cleared
      publisher.uphold_code = nil
      publisher.save!

      UploadUpholdAccessParametersJob.perform_later(publisher_id: publisher.id)
    end

  rescue UpholdRequestAccessParameters::InvalidGrantError => e
    publisher.uphold_code = nil
    publisher.save!
  end
end
