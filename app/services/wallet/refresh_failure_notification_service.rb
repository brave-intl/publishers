# typed: true

class Wallet::RefreshFailureNotificationService < BuilderBaseService
  extend T::Sig
  extend T::Helpers
  include Wallet::Structs

  # This was abstracted from oauth2_refresh_job and thus
  # the relevant spec is oauth2_refresh_job_test.rb

  def self.build
    new
  end

  def call(connection, notify: false)
    result = connection.refresh_authorization!

    case result
    when BFailure
      return result
    when Oauth2::Responses::ErrorResponse
      connection.record_refresh_failure_notification!

      if notify
        PublisherMailer.wallet_refresh_failure(connection.publisher, connection.class.provider_name).deliver_now
        return FailedWithNotification.new(result: result)
      else
        return FailedWithoutNotification.new(result: result)
      end
    end

    pass([result])
  end
end
