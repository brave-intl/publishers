module Payout
  class Service
    class WalletError < StandardError; end

    def initialize(payout_report:, publisher:, should_send_notifications: false)
      @publisher = publisher
      @payout_report = payout_report
      @should_send_notifications = should_send_notifications
    end

    def should_only_notify?
      @payout_report.nil?
    end

    def create_message(message)
      return if should_only_notify?

      PayoutMessage.create(
        payout_report: @payout_report,
        publisher: @publisher,
        message: "#{self.class.name} #{message}"
      )
    end

    # Internal: Creates entries for any reason for not paying out a publisher.
    #
    # Returns a boolean
    def skip_publisher?
      if !@publisher.has_verified_channel?
        create_message("Publisher has no verified channels")
        return true
      end

      if @publisher.excluded_from_payout?
        create_message("Publisher has been marked as excluded from payout")
        return true
      end

      if @publisher.hold?
        create_message("Publisher is currently in hold status")
        return true
      end

      if @publisher.locked?
        create_message("Publisher is currently in lock status")
        return true
      end

      if @publisher.wire_only?
        create_message("Publisher is only meant to receive wire transfers")
        return true
      end

      # Checking these classes will be removed once the following issue is addressed
      # https://github.com/brave-intl/publishers/issues/2858

      if self.class == Payout::UpholdService && @publisher.gemini_connection.present? && @publisher.selected_wallet_provider_type != 'UpholdConnection'
        # A publisher can have a gemini_connection and uphold_connection.
        # We don't want to include users who have a GeminiConnection on the Uphold Payout
        create_message("Publisher has a gemini connection and is not paid out through this job")
        return true
      end

      if self.class != Payout::PaypalService
        # A publisher can have a uphold_connection and a paypal_connection.
        # Handle the case where the wallet_provider field is nil
        connection = @publisher.selected_wallet_provider
        if connection.japanese_account?
          create_message("Publisher is located in Japan and is not paid out through this job")
          return true
        end

        if @publisher.paypal_connection.present?
          create_message("Publisher has a Paypal Connection  and is not paid out through this job")
          return true
        end
      end

      false
    end
  end
end
