# typed: true

Rails.application.reloader.to_prepare do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  PaymentClient = Payment::Client.new(
    uri: Rails.application.secrets[:payment_service_uri],
    authorization: "Bearer #{Rails.application.secrets[:payment_service_key]}"
  )
  # rubocop:enable Lint/ConstantDefinitionInBlock
end
