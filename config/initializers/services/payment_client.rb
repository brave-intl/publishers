PaymentClient = Payment::Client.new(
  uri: Rails.application.secrets[:payment_service_uri],
  authorization: "Bearer #{Rails.application.secrets[:payment_service_key]}"
)
