# typed: true

# We should eventually create a services.yml and pass in dynamic configuration for service clients.
# This will allow us to have the url defined in one place.
Rails.application.reloader.to_prepare do
  EyeshadeClient = Eyeshade::BaseApiClient.new
end
