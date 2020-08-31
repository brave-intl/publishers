module Payout
  class PaypalService < Service
    def perform
      return if skip_publisher?
      return if !@publisher.has_verified_channel? || @publisher.locked? || @publisher.excluded_from_payout? || @publisher.hold? || @publisher.wire_only?

      wallet = PublisherWalletGetter.new(publisher: @publisher).perform
      probi = wallet.referral_balance.amount_probi # probi = balance
      publisher_has_unsettled_balance = probi.to_i.positive?
      suspended = @publisher.suspended?

      unless should_only_notify?
        PotentialPayment.create(
          payout_report_id: @payout_report.id,
          name: @publisher.name,
          amount: "#{probi}",
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
        publisher_has_unsettled_balance ||= probi.positive?

        probi = wallet.channel_balances[channel.details.channel_identifier].amount_probi # probi = balance - fee
        fee_probi = wallet.channel_balances[channel.details.channel_identifier].fees_probi # fee = balance - probi

        unless should_only_notify?
          PotentialPayment.create(
            payout_report_id: @payout_report.id,
            name: "#{channel.publication_title}",
            amount: "#{probi}",
            fees: "#{fee_probi}",
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
      if publisher_has_unsettled_balance && @should_send_notifications
        send_emails(@publisher.paypal_connection)
      end
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
