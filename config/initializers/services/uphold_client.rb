# typed: true

Rails.application.reloader.to_prepare do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  UpholdClient = Uphold::Client.new(
    uri: Rails.configuration.pub_secrets[:uphold_api_uri]
  )
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
