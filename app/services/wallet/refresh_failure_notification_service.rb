class Wallet::RefreshFailureNotificationService < BuilderBaseService
  # This was abstracted from oauth2_refresh_job and thus
  # the relevant spec is oauth2_refresh_job_test.rb

  def self.build
    new
  end

  def call(connection, notify: false)
    case connection
    when UpholdConnection
      provider = "Uphold"
    when GeminiConnection
      provider = "Gemini"
    when BitflyerConnection
      provider = "Bitflyer"
    else
      raise StandardError.new("Invalid connection: #{connection.name}")
    end

    result = connection.refresh_authorization!

    return result if !notify

    case result
    when Oauth2::Responses::ErrorResponse
      PublisherMailer.wallet_refresh_failure(connection.publisher, provider).deliver_now
      connection.record_refresh_failure_notification!
    end

    result
  end
end
