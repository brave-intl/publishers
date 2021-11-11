# typed: ignore
UpholdClient = Uphold::Client.new(
  uri: Rails.application.secrets[:uphold_api_uri]
)
