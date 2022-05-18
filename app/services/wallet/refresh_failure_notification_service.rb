# typed: true

class Wallet::RefreshFailureNotificationService < BuilderBaseService
  extend T::Sig
  extend T::Helpers
  include Wallet::Structs

  ConnectionTypes = T.type_alias { T.any(UpholdConnection, BitflyerConnection, GeminiConnection) }
  ResponseTypes = T.type_alias { T.any(BFailure, FailedWithNotification, FailedWithoutNotification, BSuccess) }

  # This was abstracted from oauth2_refresh_job and thus
  # the relevant spec is oauth2_refresh_job_test.rb

  def self.build
    new
  end

  sig { override.params(connection: ConnectionTypes, notify: T::Boolean).returns(ResponseTypes) }
  def call(connection, notify: false)
    result = connection.refresh_authorization!

    case result
    when UpholdConnection, BitflyerConnection, GeminiConnection
      pass([result])
    when BFailure
      result
    when Oauth2::Responses::ErrorResponse
      connection.record_refresh_failure_notification!

      if notify
        PublisherMailer.wallet_refresh_failure(connection.publisher, connection.class.provider_name).deliver_now
        FailedWithNotification.new(result: result)
      else
        FailedWithoutNotification.new(result: result)
      end
    else
      T.absurd(result)
    end
  end
end
