class UpdateGeminiDefaultCurrencyJob
  include Sidekiq::Worker
  sidekiq_options queue: :scheduler

  def perform(gemini_id)
    connection = GeminiConnection.find(gemini_id)
    # You can't set a payment currency unless they are fully verified with Gemini.
    return unless connection.payable?

    # Make API Request to Gemini
    response = Gemini::Setting.set_payment_currency(
      token: connection.access_token,
      payment_currency: connection.default_currency
    )

    if response.payment_currency != connection.default_currency
      Raven.capture_message("Failed to set Gemini default currency", user: connection.publisher_id)
    end
  end
end
