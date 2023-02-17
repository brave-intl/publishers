# typed: true

# We should eventually create a services.yml and pass in dynamic configuration for service clients.
# This will allow us to have the url defined in one place.
Rails.application.reloader.to_prepare do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  EyeshadeClient = Eyeshade::BaseApiClient.new
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
