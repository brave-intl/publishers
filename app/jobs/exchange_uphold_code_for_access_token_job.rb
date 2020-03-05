class ExchangeUpholdCodeForAccessTokenJob < ApplicationJob
  queue_as :default

  def perform(uphold_connection_id:)
    uphold_connection = UpholdConnection.find(uphold_connection_id)
    parameters = UpholdRequestAccessParameters.new(uphold_code: uphold_connection.uphold_code).perform

    if parameters
      # The code acquired from https://uphold.com/authorize is only good for one request and times out in 5 minutes
      # it should now be cleared
      uphold_connection.update!(
        uphold_access_parameters: parameters,
        uphold_verified: true,
        uphold_code: nil
      )
    end

  rescue UpholdRequestAccessParameters::InvalidGrantError
    uphold_connection.update!(uphold_code: nil)
  end
end
