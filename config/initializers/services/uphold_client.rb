# typed: true

Rails.application.reloader.to_prepare do
  UpholdClient = Uphold::Client.new(
    uri: Rails.application.secrets[:uphold_api_uri]
  )
end
