# typed: true

class Wallet::RefreshFailureNotificationService < BuilderBaseService
  include Wallet::Structs

  # This was abstracted from oauth2_refresh_job and thus
  # the relevant spec is oauth2_refresh_job_test.rb

  def self.build
    new
  end

  def call(connection, notify: false)
    result = connection.refresh_authorization!

    case result
    when UpholdConnection, BitflyerConnection, GeminiConnection
      pass([result])
    when BFailure
      result

    when Oauth2::Responses::ErrorResponse
      if notify
        PublisherMailer.wallet_refresh_failure(connection.publisher, connection.class.provider_name).deliver_now
        connection.record_refresh_failure_notification!

        FailedWithNotification.new(result: result)
      else
        FailedWithoutNotification.new(result: result)
      end
    when Oauth2::AuthorizationCodeBase
      raise
    end
  end
end
