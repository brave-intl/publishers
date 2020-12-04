module Payout
  class PaypalService < Service
    def perform
      return if skip_publisher?

      suspended = @publisher.suspended?

      unless should_only_notify?
        PotentialPayment.create(
          payout_report_id: @payout_report.id,
          name: @publisher.name,
          amount: "0",
          fees: "0",
          publisher_id: @publisher.id,
          kind: ::PotentialPayment::REFERRAL,
          address: @publisher.paypal_connection.payer_id,
          wallet_provider_id: @publisher.paypal_connection.paypal_account_id,
          wallet_provider: ::PotentialPayment.wallet_providers['paypal'],
          paypal_bank_account_attached: @publisher.paypal_connection.verified_account,
          suspended: suspended,
          status: @publisher.last_status_update&.status
        )
      end

      # Create potential payments for channel contributions
      @publisher.channels.verified.each do |channel|
        unless should_only_notify?
          PotentialPayment.create(
            payout_report_id: @payout_report.id,
            name: "#{channel.publication_title}",
            amount: "0",
            fees: "0",
            publisher_id: @publisher.id,
            channel_id: channel.id,
            kind: PotentialPayment::CONTRIBUTION,
            address: @publisher.paypal_connection.payer_id,
            wallet_provider_id: @publisher.paypal_connection.paypal_account_id,
            wallet_provider: ::PotentialPayment.wallet_providers['paypal'],
            paypal_bank_account_attached: @publisher.paypal_connection.verified_account,
            url: "#{channel.details.url}",
            suspended: suspended,
            status: @publisher.last_status_update&.status,
            channel_stats: channel.details.stats,
            channel_type: channel.details_type
          )
        end
      end

      # Notify publishers that have money waiting, but will not will not receive funds
# (yachtcaptain23): TODO: https://github.com/brave-intl/publishers/issues/2967
#      if publisher_has_unsettled_balance && @should_send_notifications
#        send_emails(@publisher.paypal_connection)
#      end
    end

    private

    def send_emails(paypal_connection)
      if paypal_connection.verified_account?
        Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Paypal")
        PublisherMailer.paypal_missing_bank_account(@publisher).deliver_later
      end
    end
  end
end
