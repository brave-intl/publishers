class Paypal::PayoutReportPublisherIncluder < PayoutReportPublisherIncluder
  def perform
    return if !@publisher.has_verified_channel? || @publisher.locked? || @publisher.excluded_from_payout? || @publisher.hold? || @publisher.uphold_connection.present?

    wallet = PublisherWalletGetter.new(publisher: @publisher).perform
    probi = wallet.referral_balance.amount_probi # probi = balance
    publisher_has_unsettled_balance = probi.to_i.positive?
    suspended = @publisher.suspended?

    unless should_only_notify?
      PotentialPaypalPayment.create(
        payout_report_id: @payout_report.id,
        name: @publisher.name,
        amount: "#{probi}",
        fees: "0",
        publisher_id: @publisher.id,
        kind: PotentialPayment::REFERRAL,
        address: @publisher.paypal_connection.paypal_account_id,
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
        PotentialPaypalPayment.create(
          payout_report_id: @payout_report.id,
          name: "#{channel.publication_title}",
          amount: "#{probi}",
          fees: "#{fee_probi}",
          publisher_id: @publisher.id,
          channel_id: channel.id,
          kind: PotentialPayment::CONTRIBUTION,
          derived_paypal_account_id: @publisher.paypal_connection.paypal_account_id,
          url: "#{channel.details.url}",
          suspended: suspended,
          status: @publisher.last_status_update&.status,
          dervied_channel_stats: channel.details.stats,
          channel_type: channel.details_type
        )
      end
    end

    # Notify publishers that have money waiting, but will not will not receive funds
    if publisher_has_unsettled_balance && @should_send_notifications
      send_emails(payal_connection)
    end
  end

  private

  def send_emails(paypal_connection)
    if paypal_connection.verified_account?
      Rails.logger.info("Publisher #{@publisher.owner_identifier} will not be paid for their balance because they are not a verified member on Uphold")
      PublisherMailer.paypal_missing_bank_account(@publisher).deliver_later
    end
  end
end
